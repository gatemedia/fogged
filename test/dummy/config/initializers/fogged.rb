Fogged.configure do |config|
  config.provider = :aws
  config.aws_key = ENV.fetch("AWS_KEY", nil)
  config.aws_secret = ENV.fetch("AWS_SECRET", nil)
  config.aws_bucket = ENV.fetch("AWS_BUCKET", nil)
  config.aws_region = ENV.fetch("AWS_REGION", nil)
end
