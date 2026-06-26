# Changelog

## 0.4.1

This release follows up on `0.4.0` with review fixes for the modernization
release.

### Consumer notes

- AWS configuration now treats blank `aws_key`, `aws_secret`, `aws_bucket`, and
  `aws_region` values as missing. This makes blank environment variables fail
  the same way as omitted values.
- Paginated resource index requests that ask beyond the available collection now
  return an empty JSON array instead of `nil`.
- The published gem file list now includes `README.md` and `CHANGELOG.md`.

## 0.4.0

This release modernizes Fogged for current Rails and Ruby applications and
removes unmaintained dependencies. Consumers should treat this as a breaking
release and review the notes below before upgrading.

### Breaking changes

- Ruby 3.4 or newer is now required. The gemspec supports Ruby `>= 3.4` and
  `< 4.1`.
- Rails 7 or newer is now required. The gemspec supports Rails `>= 7.0` and
  `< 9.0`.
- `aws_region` is now required for AWS S3 configuration. Applications must set
  `config.aws_region`; otherwise `Fogged.resources` raises
  `ArgumentError, "AWS region is mandatory"`.
- `fog-aws` is no longer a Fogged dependency. Applications that directly use
  `Fog::Storage`, `Fog::Storage::AWS`, `Fog.mock!`, or other Fog constants via
  Fogged's transitive dependency must either add and manage `fog-aws`
  themselves or migrate those call sites to Fogged's storage wrapper.
- Active Model Serializers is no longer a Fogged dependency.
  `Fogged::ResourceSerializer` no longer subclasses
  `ActiveModel::Serializer`, and AMS-specific APIs such as serializer options,
  inheritance, and embedding this serializer inside consumer AMS serializers are
  no longer supported by Fogged.
- `has_one_resource` now sets the underlying `belongs_to :resource`
  association to `optional: true` by default. This preserves legacy Fogged
  behavior on modern Rails, but applications that intentionally relied on Rails'
  default required `belongs_to` validation for this association should add their
  own presence validation.

### Consumer migration notes

- The Fogged controller JSON payload shape is intended to stay compatible for
  `index`, `show`, and `create` responses. The implementation now renders
  explicit hashes instead of delegating to Active Model Serializers.
- AWS-backed storage now uses `aws-sdk-s3` through `Fogged::Storage::Aws`.
  Fogged keeps wrapper methods for the storage operations used by the gem, such
  as `directories.get`, `files.get`, `files.head`, `files.create`, `files.new`,
  `request_url`, `public_url`, `copy`, `save`, and `destroy`.
- Test mode now uses `Fogged::Storage::Mock` through `Fogged.test_mode!`
  instead of `Fog.mock!`.
- Consumers with initializers or monkey patches targeting
  `Fog::Storage::AWS::File` must remove or guard those patches, because Fogged
  no longer loads that class.

### Dependency changes

- Removed `active_model_serializers`.
- Removed `fog-aws`.
- Added `aws-sdk-s3`.
- Updated `fastimage` to `~> 2.4`.
- Restricted `mime-types` to `< 4.0`.

### Tooling and release changes

- Version bumped to `0.4.0`.
- CI now runs on Ruby 3.4 and Ruby 4.0.
- GitHub Actions checkout was updated to `actions/checkout@v4`.
