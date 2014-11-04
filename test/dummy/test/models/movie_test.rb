require "test_helper"

class MovieTest < ActiveSupport::TestCase
  def setup
    @movie = Movie.new(:name => "test")
  end

  test "should save movie with no resources" do
    assert @movie.save
  end

  test "should save movie with several resources" do
    @movie.resources = fogged_resources(:resource_text_1, :resource_text_2)

    assert @movie.save
  end

  test "should not save movie with uploading resource" do
    @movie.resources = fogged_resources(:resource_text_1, :resource_text_2)
    resource = fogged_resources(:resource_text_4)
    resource.update!(:uploading => true)
    @movie.resources << resource

    refute @movie.save
  end
end
