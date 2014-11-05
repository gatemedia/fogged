# Fogged

Fogged is meant to ease the use of Resources which are saved on a cloud (Google Drive, AWS S3, Rackspace Files, Open Stack or others) in a Rails application.

Think about have a User with a S3 Resource as it's image or a Movie with many S3 Resources as thumbnails.

It provides a model, a controller and other Rails utils.

## Prerequisites
Fogged has been implemented for:
* Rails 4.x
* Ruby 2.x but should work for Ruby 1.9

## Installation

```shell
$ gem install fogged
```

or add to your `Gemfile`

```ruby
gem "fogged"
```

## Configuration
Fogged *needs* to be configured. Among other things you need to select a cloud provider. Fogged *will not* work out of the box without a configuration.

The easiest way to configure Fogged is to add a new initializer in your Rails application:

```ruby
# file: config/initializers/fogged.rb
Fogged.configure do |config|
  config.provider = :aws
  config.aws_key = ENV["AWS_KEY"]
  config.aws_secret = ENV["AWS_SECRET"]
  config.aws_bucket = ENV["AWS_BUCKET"]
  config.aws_region = ENV["AWS_REGION"]
end
```

* `provider`: the selected provider. Currently Fogged supports these: `:aws` (More to come?)

### AWS S3 Config
* `aws_key`: Your AWS key.
* `aws_secret`: Your AWS secret.
* `aws_bucket`: The AWS bucket which will host the resources.
* `aws_region`: The AWS region. Optional.

## Optional support
Fogged supports any type of resource. However, for video resources, Fogged provides a support for [Zencoder](https://zencoder.com/en/). When creating a new video, Fogged will enqueue a new job on Zencoder to create several thumbnails and several web compatible videos(namely a MPEG, H264 and WEBM).

To use this, just add the `zencoder` and the `delayed_job_active_record` gems in your application and Fogged will pick it up.

## Dependencies

Fogged use these libs:
* [Fog](http://fog.io). See all the supported [providers](http://fog.io/about/provider_documentation.html).
* [FastImage](https://github.com/sdsykes/fastimage).

## License

This project rocks and uses MIT-LICENSE.
