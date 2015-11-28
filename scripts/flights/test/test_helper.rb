require 'test/unit'

module TestHelper
  def assert_nil(obj)
    assert_equal(nil, obj)
  end

  def assert_empty(list)
    assert_equal(0, list.size)
  end
end