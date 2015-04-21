require "test_helper"

module Fogged
  module Resources
    class AWSThumbnailJobTest < ActiveSupport::TestCase
      def setup
        super
        @resource = fogged_resources(:resource_thumbnail)
        Fogged.thumbnail_sizes = %w(50x50 100x100)
      end

      test "should thumbnail the image" do
        in_a_fork do
          require "mini_magick"
          Fogged.configure

          Resource.any_instance.expects(:url).twice.returns("http://lorempixel.com/800/600/cats")
          job = AWSThumbnailJob.new(@resource.id)

          job.perform

          Fogged.thumbnail_sizes.each_with_index do |size, index|
            key = @resource.send(:fogged_name_for, :thumbnails, index)
            f = Fogged.resources.files.get(key)
            Tempfile.open(["thumbnail", ".png"]) do |t|
              t.write(f.body)
              t.flush
              output_size = FastImage.size(t.path)
              assert_equal size, "#{output_size.first}x#{output_size.second}"
            end
          end
          refute @resource.encoding?
          assert_equal 100, @resource.reload.encoding_progress
        end
      end

      test "should not thumbnail with unknown image" do
        in_a_fork do
          require "mini_magick"
          Fogged.configure

          Resource.any_instance.expects(:url).returns("http://localhost:7777/image")
          job = AWSThumbnailJob.new(@resource.id)

          assert_raise(MiniMagick::Error) do
            job.perform
          end
        end
      end
    end
  end
end
