# frozen_string_literal: true

require "erb"

module Fogged
  module Storage
    class Base
      attr_reader :directories

      def initialize
        @directories = Directories.new(self)
      end

      def request_url(bucket_name:, object_name: nil)
        public_url(bucket_name, object_name)
      end
    end

    class Aws < Base
      attr_reader :client, :resource

      def initialize(access_key_id:, secret_access_key:, region: nil)
        super()
        options = {
          access_key_id:,
          secret_access_key:
        }
        options[:region] = region if region
        @resource = ::Aws::S3::Resource.new(**options)
        @client = @resource.client
      end

      def public_url(bucket_name, object_name = nil)
        bucket = resource.bucket(bucket_name)
        return "#{bucket.url.delete_suffix("/")}/" unless object_name

        bucket.object(object_name).public_url
      end

      def get_object(bucket_name, key)
        client.get_object(bucket: bucket_name, key:).body.read
      rescue ::Aws::S3::Errors::NotFound, ::Aws::S3::Errors::NoSuchKey
        nil
      end

      def object_exists?(bucket_name, key)
        client.head_object(bucket: bucket_name, key:)
        true
      rescue ::Aws::S3::Errors::NotFound, ::Aws::S3::Errors::NoSuchKey
        false
      end

      def put_object(bucket_name, key, body, options = {})
        client.put_object(
          object_options(options).merge(
            bucket: bucket_name,
            key:,
            body:
          )
        )
      end

      def delete_object(bucket_name, key)
        client.delete_object(bucket: bucket_name, key:)
      end

      def copy_object(source_bucket, source_key, target_bucket, target_key, options = {})
        client.copy_object(
          object_options(options).merge(
            bucket: target_bucket,
            key: target_key,
            copy_source: "#{url_encode(source_bucket)}/#{url_encode(source_key)}"
          )
        )
      end

      def list_keys(bucket_name, prefix = nil)
        resource.bucket(bucket_name).objects(prefix:).map(&:key)
      end

      def put_object_url(bucket_name, key, expires_at, headers = {})
        ::Aws::S3::Presigner.new(client:).presigned_url(
          :put_object,
          presign_options(headers).merge(
            bucket: bucket_name,
            key:,
            expires_in: expires_in(expires_at)
          )
        )
      end

      private

      def object_options(options)
        result = {}
        result[:acl] = "public-read" if options[:public]
        result[:content_type] = options[:content_type] if options[:content_type]
        result
      end

      def presign_options(headers)
        {}.tap do |result|
          result[:content_type] = headers["Content-Type"] if headers["Content-Type"]
          result[:acl] = headers["x-amz-acl"] if headers["x-amz-acl"]
        end
      end

      def expires_in(expires_at)
        [(expires_at.to_i - Time.now.to_i), 1].max
      end

      def url_encode(value)
        ERB::Util.url_encode(value)
      end
    end

    class Mock < Base
      StoredObject = Struct.new(:body, :content_type, :public, keyword_init: true)

      def initialize
        super
        @objects = Hash.new { |hash, bucket| hash[bucket] = {} }
      end

      def public_url(bucket_name, object_name = nil)
        ["https://#{bucket_name}.s3.amazonaws.com", object_name].compact.join("/") + (object_name ? "" : "/")
      end

      def get_object(bucket_name, key)
        objects_for(bucket_name)[key]&.body
      end

      def object_exists?(bucket_name, key)
        objects_for(bucket_name).key?(key)
      end

      def put_object(bucket_name, key, body, options = {})
        objects_for(bucket_name)[key] = StoredObject.new(
          body: read_body(body),
          content_type: options[:content_type],
          public: options[:public]
        )
      end

      def delete_object(bucket_name, key)
        objects_for(bucket_name).delete(key)
      end

      def copy_object(source_bucket, source_key, target_bucket, target_key, options = {})
        source = objects_for(source_bucket).fetch(source_key)
        put_object(
          target_bucket,
          target_key,
          source.body,
          options.merge(content_type: source.content_type)
        )
      end

      def list_keys(bucket_name, prefix = nil)
        objects_for(bucket_name).keys.select do |key|
          prefix.blank? || key.start_with?(prefix)
        end
      end

      def put_object_url(bucket_name, key, _expires_at, headers = {})
        query = {
          "Content-Type" => headers["Content-Type"],
          "x-amz-acl" => headers["x-amz-acl"]
        }.compact.to_query
        [public_url(bucket_name, key), query.presence].compact.join("?")
      end

      private

      def objects_for(bucket_name)
        @objects[bucket_name]
      end

      def read_body(body)
        body.respond_to?(:read) ? body.read : body.to_s
      end
    end

    class Directories
      def initialize(storage)
        @storage = storage
      end

      def get(key, prefix: nil)
        Directory.new(@storage, key, prefix:)
      end

      def create(key:)
        Directory.new(@storage, key)
      end
    end

    class Directory
      attr_reader :key, :files

      def initialize(storage, key, prefix: nil)
        @storage = storage
        @key = key
        @files = Files.new(storage, self, prefix:)
      end
    end

    class Files
      include Enumerable

      def initialize(storage, directory, prefix: nil)
        @storage = storage
        @directory = directory
        @prefix = prefix
      end

      def each
        return enum_for(:each) unless block_given?

        @storage.list_keys(@directory.key, @prefix).each do |key|
          file = get(key)
          yield file if file
        end
      end

      def get(key)
        body = @storage.get_object(@directory.key, key)
        return if body.nil?

        File.new(@storage, @directory, key).tap do |file|
          file.body = body
        end
      end

      def head(key)
        return unless @storage.object_exists?(@directory.key, key)

        File.new(@storage, @directory, key)
      end

      def create(key:, body: "", public: nil, content_type: nil)
        new(key:, body:, public:, content_type:).tap(&:save)
      end

      def new(key:, body: "", public: nil, content_type: nil)
        File.new(
          @storage,
          @directory,
          key,
          body:,
          public:,
          content_type:
        )
      end
    end

    class File
      attr_accessor :body, :content_type
      attr_writer :public
      attr_reader :key

      def initialize(storage, directory, key, body: "", public: nil, content_type: nil)
        @storage = storage
        @directory = directory
        @key = key
        @body = body
        @public = public
        @content_type = content_type
      end

      def save # rubocop:disable Naming/PredicateMethod
        @storage.put_object(
          @directory.key,
          key,
          body,
          public: public?,
          content_type:
        )
        true
      end

      def destroy
        @storage.delete_object(@directory.key, key)
      end

      def copy(target_bucket, target_key)
        @storage.copy_object(
          @directory.key,
          key,
          target_bucket,
          target_key,
          public: public?,
          content_type:
        )
        self.class.new(@storage, Directory.new(@storage, target_bucket), target_key)
      end

      def service
        @storage
      end

      private

      def public?
        @public == true || @public == "public_read" || @public == "public-read"
      end
    end
  end
end
