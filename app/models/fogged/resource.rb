module Fogged
  class Resource < ActiveRecord::Base
    validates :extension, :content_type, :presence => true

    before_save :ensure_token
    after_destroy :destroy_fogged_file

    def self.search(params)
      results = all

      if params[:query]
        results = results.where(
          "#{table_name}.name LIKE :query",
          :query => "%#{params[:query].to_s.downcase}%"
        )
      end

      results
    end

    def upload_url
      fogged_file.service.put_object_url(
        Fogged.resources.key,
        fogged_file.key,
        2.minutes.from_now,
        "Content-Type" => content_type,
        "x-amz-acl" => "public-read"
      )
    end

    def url
      Fogged.file_public_url(fogged_name)
    end

    def h264_url
      return unless video?
      url.gsub(fogged_name, fogged_name_for(:h264))
    end

    def mpeg_url
      return unless video?
      url.gsub(fogged_name, fogged_name_for(:mpeg))
    end

    def webm_url
      return unless video?
      url.gsub(fogged_name, fogged_name_for(:webm))
    end

    def thumbnail_urls
      return unless video?
      5.times.map do |n|
        url.gsub(fogged_name, fogged_name_for(:thumbnails, n))
      end
    end

    def video?
      content_type.start_with?("video/")
    end

    def image?
      content_type.start_with?("image/")
    end

    def encoding?
      return false unless video? && encoding_progress.present?
      encoding_progress < 100
    end

    def process!
      find_size! if image?
      encode! if video?
    end

    def write(content)
      fogged_file.body = content
      fogged_file.save
    end

    private

    def find_size!
      if Fogged.test_enabled
        update!(
          :width => 800,
          :height => 600
        )
      else
        size = FastImage.size(url)
        update!(
          :width => size.first,
          :height => size.second
        ) unless size.blank?
      end
    end

    def encode!
      return unless Fogged.zencoder_enabled
      Resources::Encoder.for(self).encode!
    end

    def ensure_token
      self.token = generate_token if token.blank?
    end

    def generate_token
      loop do
        a_token = SecureRandom.hex(16)
        break a_token unless Resource.find_by(:token => a_token)
      end
    end

    def fogged_file
      return @fogged_file if defined?(@fogged_file)

      files = Fogged.resources.files
      @fogged_file = files.get(fogged_name) || files.create(
        :key => fogged_name,
        :body => "",
        :public => true,
        :content_type => content_type
      )
    end

    def fogged_name
      "#{token}.#{extension}"
    end

    def fogged_name_for(type, number = 0)
      case type
      when :h264
        "#{token}-h264.mp4"
      when :mpeg
        "#{token}-mpeg.mp4"
      when :webm
        "#{token}-webm.webm"
      when :thumbnails
        "#{token}-thumbnail-#{number}.png"
      else
        fail(ArgumentError, "Can't get fogged name of #{type}")
      end
    end

    def destroy_fogged_file
      fogged_file.destroy
    end
  end
end
