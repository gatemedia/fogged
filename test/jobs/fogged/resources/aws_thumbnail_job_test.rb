require "test_helper"

module Fogged
  module Resources
    class AWSThumbnailJobTest < ActiveSupport::TestCase
      def setup
        super
        @resource = fogged_resources(:resource_thumbnail)
      end

      test "should thumbnail the image" do
        in_a_fork do
          require "mini_magick"
          Fogged.configure

          Resource.any_instance.expects(:url).returns("http://lorempixel.com/800/600/cats")
          job = AWSThumbnailJob.new(@resource.id, "50x50", "foobar")

          job.perform

          f = Fogged.resources.files.get("foobar")
          Tempfile.open(["thumbnail", ".png"]) do |t|
            t.write(f.body)
            t.flush
            assert_equal [50, 50], FastImage.size(t.path)
          end
        end
      end

      test "should not thumbnail with unknown image" do
        in_a_fork do
          require "mini_magick"
          Fogged.configure

          Resource.any_instance.expects(:url).returns("http://localhost:7777/image")
          job = AWSThumbnailJob.new(@resource.id, "50x50", "foobar")

          assert_raise(MiniMagick::Error) do
            job.perform
          end
        end
      end

      test "should not thumbnail with wrong size" do
        in_a_fork do
          require "mini_magick"
          Fogged.configure

          Resource.any_instance.expects(:url).returns("http://lorempixel.com/800/600/cats")
          job = AWSThumbnailJob.new(@resource.id, "abc", "foobar")

          assert_raise(MiniMagick::Error) do
            job.perform
          end
        end
      end
    end
  end
end
