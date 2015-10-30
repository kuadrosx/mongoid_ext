require 'helper'

class DocumentExtTest < Minitest::Test
  def test_find!
    Mongoid.raise_not_found_error = false
    Avatar.find(404)
    assert_raises Mongoid::Errors::DocumentNotFound do
      Avatar.find!(404)
    end
    Mongoid.raise_not_found_error = true
  end
end
