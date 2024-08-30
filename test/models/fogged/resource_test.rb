require "test_helper"

module Fogged
  class ResourceTest < ActiveSupport::TestCase
    def setup
      super
      @resource = Resource.new(
        extension: "txt",
        uploading: false,
        content_type: "text/plain",
        name: "Test"
      )
    end

    test "resource should be valid" do
      assert @resource.save
    end

    %w[extension content_type].each do |field|
      test "resource without #{field} should not be saved" do
        @resource.send("#{field}=", nil)

        assert_not @resource.save
      end
    end

    test "resource should have a token after being saved" do
      assert_not @resource.token
      assert @resource.save
      assert @resource.token
    end

    test "resource should have an upload url" do
      @resource.save!
      assert @resource.upload_url.include?(Fogged.aws_bucket)
    end

    test "resource should have an url" do
      @resource.save!
      assert @resource.url.include?(@resource.token)
      assert @resource.url.include?(@resource.extension)
    end

    test "resource should destroy fogged file after destroy" do
      @resource.save!
      @resource.expects(:destroy_fogged_file).once.returns(nil)
      @resource.destroy
    end

    test "should process resource image" do
      @resource = fogged_resources(:resource_png_1)

      @resource.process!
      assert_equal 800, @resource.width
      assert_equal 600, @resource.height
      assert_not @resource.encoding?
    end

    test "should process resource video" do
      @resource = fogged_resources(:resource_mov_1)

      @resource.process!

      assert_not @resource.encoding?
      assert_not @resource.encoding_job_id
    end

    test "should process resource video with zencoder enabled" do
      in_a_fork do
        require "zencoder"
        require "delayed_job_active_record"
        Rails.application.config.active_job.queue_adapter = :delayed_job
        Fogged.configure

        @resource = fogged_resources(:resource_mov_1)
        Zencoder::Job.expects(:create).returns(
          OpenStruct.new(body: create_output)
        )

        @resource.process!

        assert @resource.encoding?
        assert_equal "1234567890", @resource.encoding_job_id
      end
    end

    test "should generate a token before writing file" do
      assert_not @resource.token
      @resource.write("foo")
      assert @resource.token
    end

    private

    def create_output
      {
        id: 1_234_567_890
      }.with_indifferent_access
    end
  end
end
