require 'helper'

class OpenStructTest < Minitest::Test
  def from_db
    UserConfig.find(@config.id)
  end

  def setup
    @config = UserConfig.create!
  end

  def test_add_new_keys
    entries = MongoidExt::OpenStruct.new
    entries.new_key = "my new key"
    @config.entries = entries
    @config.save

    assert_equal from_db.entries.new_key, "my new key"
  end
end
