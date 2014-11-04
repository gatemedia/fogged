Fogged.configure do |config|
  config.provider = :aws
  config.aws_key = ENV["AWS_KEY"]
  config.aws_secret = ENV["AWS_SECRET"]
  config.aws_bucket = ENV["AWS_BUCKET"]
  config.aws_region = ENV["AWS_REGION"]
end
