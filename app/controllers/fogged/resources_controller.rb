# The Resource API. This API has only 3 methods: create, confirm and destroy.
#
# To create a new resource, call the create method with a filename and a
# content_type, you will get a resource as a result. This resource has an
# upload_url you can use to put your content. Caution, this url is valid only
# for 2 minutes.
#
# When uploading a resource, two http headers are *mandatory*:
# * Content-Type, which *must* be the same value as the one used to create the
#   resource
# * Set the acl to public read. Eg. on AWS send the x-amz-acl header set to
#   "public-read". This ensures that the resource is publicly readable.
#
# The upload can fail if these two flags/settings are missing.
#
# Once you finished uploading the resource, you can confirm it with the method
# confirm. You MUST confirm a resource in order to use it elsewhere (eg. in the
# Event api). Once confirmed, a resource can't be updated. For example, if you
# want to update the resource content, create a new one. A resource has these
# fields:
#
# id - the resource's id
# name - the resource's name
# upload_url - the secured url where you can upload your content. This link has
#              already all the correct parameters for S3. Do not change them.
# url - the public url where you can read the content
# h264_url - the url of the h264 file. Only for video resources
# mpeg_url - the url of the mpeg file. Only for video resources
# webm_url - the url of the webm file. Only for video resources
# thumbnail_urls - the urls of the thumbnails. Only for video resources
# encoding_progress - the progress of the encoding in %. Only for video
#                     resources
#
# Examples
#
# {
#   "resource": {
#     "id": 1,
#     "upload_url": "https:...",
#     "url": "https:..."
#   }
# }
#
# {
#   "resource": {
#     "id": 42145,
#     "name": "Resource 6",
#     "url": "https://...",
#     "h264_url": "https://...",
#     "mpeg_url": "https://...",
#     "webm_url": "https://...",
#     "thumbnail_urls": [
#       "https://...",
#       "https://...",
#       "https://...",
#       "https://...",
#       "https://..."
#     ],
#     "encoding_progress": 0
#   }
# }
module Fogged
  class ResourcesController < Fogged.parent_controller.constantize
    before_action :select_resourceables, :only => :index
    before_action :select_resource, :only => [:confirm, :destroy, :show, :update]
    skip_before_action :verify_authenticity_token, :only => :zencoder_notification

    # List all resources. Parameter type is mandatory. It indicates in which
    # "context" you want all resources. You can refine the search, using
    # using parameters type_id or type_ids, which will select the context
    # objects before retrieving the resources. Pagination options are
    # available. Search options are available.
    #
    # type - the context/type in which the resources search is done. Mandatory
    # type_id - the specific type id
    # type_ids - the specific type ids
    # query - text search (insensitive) on the resource's name
    #
    # Example
    #
    # GET /api/v1/resources?type=group&ids[]=2&ids[]=3
    # GET /api/v1/resources?type=group
    #
    # Returns an array of Resources found
    # Raises 400 if the given type is unknown
    # Raises 500 if an error occurs
    def index
      resources = @resourceables.map do |resourceable|
        resourceable.resources.search(params)
      end

      render :json => paginate(resources.flatten.uniq),
             :meta => @meta,
             :each_serializer => ResourceSerializer
    end

    # Get the resource.
    #
    # id - the resource's id
    #
    # Example
    #
    # GET /api/v1/resources/123
    #
    # Returns the Resource
    # Raises 404 if the Resource is not found
    # Raises 500 if an error occurs
    def show
      render :json => @resource,
             :serializer => ResourceSerializer
    end

    # Create a new resource. You must provide a filename (example: foo.png)
    # and a content_type (example: "image/png"). This content_type must be the
    # same as the one used with the upload_url.
    #
    # resource - a hash with a name (optional), a filename and a content_type
    #
    #
    # Examples
    #
    # POST /api/v1/resources
    # {
    #   "resource": {
    #     "name": "The ultimate ruby"
    #     "filename": "ruby.png"
    #     "content_type": "image/png"
    #   }
    # }
    #
    # Return the created resource which will be marked as uploading.
    # Raises 400 if resource params are not valid.
    # Raises 500 if an error occurs.
    def create
      resource = Resource.create!(
        :name => resource_params.require(:name),
        :extension => extension(resource_params.require(:filename)),
        :content_type => resource_params.require(:content_type),
        :uploading => true
      )

      render :json => resource,
             :serializer => ResourceSerializer,
             :include_upload_url => true
    end

    # Update a Resource. You can update the name of a Resource or its context
    # object
    #
    # id - the resource's id
    # resource - the resource params
    #
    # Example
    #
    # PUT /api/v1/resources/1
    # {
    #   "resource": {
    #     "name": "Updated"
    #   }
    # }
    #
    # Returns the updated Resource
    # Raises 400 if the parameters are invalid
    # Raises 404 if the resource or the context object can't be found
    # Raises 500 if an error occurs
    def update
      @resource.update!(resource_params.permit(:name))

      show
    end

    # Confirm a resource. You MUST confirm a resource before using it.
    #
    # id - the resource id
    #
    # Examples
    #
    # PUT /api/v1/resources/1/confirm
    #
    # Return the confirmed resource. Note that the upload_url will not be
    # present in the response.
    # Raises 500 if a server errors occurs
    def confirm
      @resource.process!
      @resource.update!(:uploading => false)
      show
    end

    # Destroy a resource. You can choose to destroy a resource. This
    # will also destroy the content on S3.
    #
    # id - the resource id
    #
    # Examples
    #
    # DELETE /api/v1/resources/1
    #
    # Return an empty response with 204(No content)
    # Raises 500 if a server errors occurs
    def destroy
      @resource.destroy!
      head :no_content
    end

    def zencoder_notification
      if (resource = Resource.find_by(:encoding_job_id => job_params[:id])) &&
         (file = params[:outputs].try(:first)) &&
         job_params[:state] == "finished"

        resource.update!(
          :encoding_progress => 100,
          :width => file[:width],
          :height => file[:height],
          :duration => file[:duration_in_ms].to_f / 1000.0
        )
      end

      head :ok
    end

    private

    def select_resourceables
      ids = params[:type_id] || params[:type_ids]
      ids = [ids] unless ids.respond_to?(:to_ary)
      @resourceables = resourceable_clazz.all
      @resourceables = resourceable_clazz.where(:id => ids) if ids.try(:any?)
    end

    def resourceable_clazz
      @_resourceable_clazz ||= resource_type_param.try(:classify)
                               .try(:safe_constantize)
      unless @_resourceable_clazz
        fail(ArgumentError, "Unknown resourceable type: #{params[:type]}")
      end
      @_resourceable_clazz
    end

    def resource_type_param
      params.require(:type)
    end

    def select_resource
      @resource = Resource.find(params[:id])
    end

    def resource_params
      params.require(:resource).permit(:name, :filename, :content_type)
    end

    def extension(filename)
      extension = File.extname(filename)
      extension.tap { |e| e.slice!(0) }
    end

    def paginate(result)
      page = Integer(params[:page] || 1)
      count = Integer(params[:count] || 50).to_i
      offset = (page - 1) * count
      total = result.size
      @meta = {
        :pagination => {
          :total => total,
          :remaining => [total - offset - count, 0].max
        }
      }

      case result
      when Array
        result.slice(offset, count)
      else
        result.limit(count).offset(offset)
      end
    end

    def job_params
      params.require(:job).permit(:id, :state)
    end
  end
end
