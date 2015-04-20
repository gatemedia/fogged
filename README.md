# Fogged
[![Build Status](https://travis-ci.org/gatemedia/fogged.svg?branch=master)](https://travis-ci.org/gatemedia/fogged)

Fogged is meant to ease the use of Resources which are saved on a cloud (Google Drive, AWS S3, Rackspace Files, Open Stack or others) in a Rails application.

Think about have a User with a S3 Resource as it's image or a Movie with many S3 Resources as thumbnails.

It provides a model, a controller and other Rails utils.

## Prerequisites
Fogged has been implemented for:
* Rails 4.2.x
* Ruby 2.x but should work for Ruby 1.9

However this gem is built against:
* ruby 1.9.3
* ruby 2.0.0
* ruby 2.1.3
* ruby 2.2.0
* ruby 2.2.2

## Installation

```shell
$ gem install fogged
```

or add to your `Gemfile`

```ruby
gem "fogged"
```

Copy the migrations from Fogged:
```shell
$ rake fogged:install:migrations
```

## Configuration
Fogged *needs* to be configured. Among other things you need to select a cloud provider. Fogged *will not* work out of the box without a configuration.

The easiest way to configure Fogged is to add a new initializer in your Rails application:

```ruby
# file: config/initializers/fogged.rb
Fogged.configure do |config|
  config.provider = :aws
  config.parent_controller = "MyBasicController"
  config.aws_key = ENV["AWS_KEY"]
  config.aws_secret = ENV["AWS_SECRET"]
  config.aws_bucket = ENV["AWS_BUCKET"]
  config.aws_region = ENV["AWS_REGION"]
end

Fogged.test_mode! if Rails.env.test?
```

* `provider`: the selected provider. Currently Fogged supports these: `:aws` (More to come?)
* `parent_controller`: the parent controller for the `ResourcesController`. Defaults to `"ApplicationController"`.

* `Fogged.test_mode!` will put Fogged into a test mode configuring it with a mock cloud storage.

### AWS S3 Config
* `aws_key`: Your AWS key.
* `aws_secret`: Your AWS secret.
* `aws_bucket`: The AWS bucket which will host the resources.
* `aws_region`: The AWS region. Optional.

## Optional support
### Zencoder
Fogged supports any type of resource. However, for video resources, Fogged provides a support for [Zencoder](https://zencoder.com/en/). When creating a new video, Fogged will enqueue a new job on Zencoder to create several thumbnails and several web compatible videos(namely a MPEG, H264 and WEBM).

To use this, just add the `zencoder` gem and any ActiveJob backend (eg. `delayed_job`) in your application and Fogged will pick it up.

### Image thumbnails
Fogged can auto create thumbnails for images. For this, you'll to need to have the `mini_magick` gem and any ActiveJob backend installed.

To configure the desired sizes, in the `Fogged.configure` block, use `thumbnail_sizes`:
```ruby
Fogged.configure do |config|
  # ...
  thumbnail_sizes = %w(50x50 150x150)
end
```

When processing an image, Fogged will enqueue as many jobs as necessary to create each thumbnail.

The thumbnail urls can be retrieved, using `Fogged::Resource#thumbnail_urls`.

## How to use it

### Model

The `Fogged::Resource` is the model. It provides some helper methods to get the content type, the public url and some flags to know if the resource is of type video or an image. In addition, when Zencoder is available, it also has some methods to get the encoding progress.

### Associations
Any `ActiveRecord::Base` object can have one or n resources.

To link with one resource, add a `resource_id` column and use `acts_as_having_one_resource`.

```ruby
class Poster < ActiveRecord::Base
  acts_as_having_one_resource
end
```

To link with multiple resources, you *must* have a join table and use `acts_as_having_many_resources`.

```ruby
class MovieFoggedResource < ActiveRecord::Base
  belongs_to :movie
  belongs_to :resource, :class_name => "Fogged::Resource"
end


class Movie < ActiveRecord::Base
  has_many :movie_fogged_resources
  acts_as_having_many_resources :through => :movie_fogged_resources
end
```

Both macros accept any option you could send to `belongs_to` and `has_many`. As an example, both associations are set with `:dependent => :destroy`. You can change this behavior with

```ruby
class Poster < ActiveRecord::Base
  acts_as_having_one_resource :dependent => nil
end
```

### Controller
A `Fogged::ResourcesController` is provided. It *does not* handle the creation of Resource with the upload if the content. This upload is left to the clients. See the docs.

To install the controller routes, mount the `Fog::Engine` in your `routes.rb` file:
```ruby
# in routes.rb
mount Fogged::Engine => "/"
```

This will mount the following routes:
```shell
    resources GET    /resources(.:format)             fogged/resources#index
              POST   /resources(.:format)             fogged/resources#create
     resource GET    /resources/:id(.:format)         fogged/resources#show
              PATCH  /resources/:id(.:format)         fogged/resources#update
              PUT    /resources/:id(.:format)         fogged/resources#update
              DELETE /resources/:id(.:format)         fogged/resources#destroy
              PUT    /resources/:id/confirm(.:format) fogged/resources#confirm
```

Of course you can decide to mount it in a sub url:
```ruby
# in routes.rb
mount Fogged::Engine => "/files"
```

### Serializer
A `Fogged::ResourceSerializer` is provided. It is used by the `Fogged::ResourcesController` to serialize the `Fogged::Resource` object. If you are using Active Model Serializers in you project you can also reference it, to embed the `Fogged::Resource` into an other object.

## Dependencies

Fogged uses these libs:
* [Fog](http://fog.io). See all the supported [providers](http://fog.io/about/provider_documentation.html)
* [FastImage](https://github.com/sdsykes/fastimage)
* [Active Model Serializers](https://github.com/rails-api/active_model_serializers)

## License

This project rocks and uses MIT-LICENSE.
