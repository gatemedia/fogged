Fogged.configure do |config|
  config.provider = :aws
  config.aws_key = "1234567890"
  config.aws_secret = "1234567890"
  config.aws_bucket = "test"
  config.aws_region = "eu-west"
end
