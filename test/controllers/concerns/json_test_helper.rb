module JsonTestHelper
  extend ActiveSupport::Concern

  private

  def assert_json_objects(objects, json_objects, *fields)
    json_objects = [json_objects].flatten.compact

    objects.flatten!
    json_objects.flatten!

    unless json_objects.empty? || json_objects.first.exclude?(:id)
      objects.sort_by!(&:id)
      json_objects.sort_by! { |e| e[:id] }
    end
    assert_equal objects.size, json_objects.size
    objects.zip(json_objects).each do |object, json_object|
      assert_json_object(object, json_object, *fields)
    end
  end

  def assert_json_object(object, json_object, *fields)
    raise(ArgumentError, "fields can't be empty") if fields.blank?

    fields.each do |field|
      expected_value = object.send(field)

      if expected_value.is_a?(ActiveSupport::TimeWithZone)
        assert_equal expected_value.iso8601, json_object[field]
      elsif expected_value.is_a?(Date)
        assert_equal Oj.load(expected_value.to_json), json_object[field]
      elsif expected_value.is_a?(Enumerable) && expected_value.all? { |e| e.is_a?(Hash) }
        assert_equal expected_value.map(&:symbolize_keys), json_object[field]
      elsif expected_value.is_a?(Enumerable)
        assert_equal expected_value.sort, json_object[field].sort
      elsif expected_value.is_a?(Symbol)
        assert_equal expected_value.to_s, json_object[field]
      else
        assert_equal expected_value, json_object[field]
      end
    end
  end
end
