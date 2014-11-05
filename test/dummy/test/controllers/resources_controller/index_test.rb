require "test_helper"

class ResourcesControllerIndexTest < ActionController::TestCase
  tests Fogged::ResourcesController
  include ResourceTestHelper

  def setup
    super
    @movie = movies(:movie_one)
  end

  test "should index all resources for movies" do
    get :index, :type => "movie", :use_route => :fogged

    assert_json_resources(Movie.all.map(&:resources).flatten)
  end

  test "should index resources for a movie" do
    get :index, :type => "movie", :type_id => @movie.id, :use_route => :fogged

    assert_json_resources(@movie.resources.to_a)
  end

  test "should index resources for movies" do
    resources = movies(:movie_one, :movie_two).map(&:resources).flatten
    get :index,
        :type => "movie",
        :type_ids => movies(:movie_one, :movie_two).map(&:id),
        :use_route => :fogged

    assert_json_resources(resources)
  end

  test "should index resources for a movie with search query on name" do
    res = Fogged::Resource.create(
      :name => "footest barish",
      :extension => "txt",
      :content_type => "text/plain"
    )
    @movie.resources << res

    get :index,
        :type => "movie",
        :type_id => @movie.id,
        :query => "test",
        :use_route => :fogged

    assert_json_resources([res])
  end

  test "should index resources with invalid movie id" do
    get :index, :type => "movie", :type_id => 1234567890, :use_route => :fogged

    assert_json_resources([])
  end
end
