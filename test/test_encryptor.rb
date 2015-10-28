require 'helper'

class EncryptorTest < Minitest::Test
  def setup
    @cc = CreditCard.create(:number => 12_345, :data => { :month => 10, :year => 2014 })
    @cc.reload
  end

  def test_load_number
    assert_equal @cc.number, 12_345
  end

  def test_load_hash
    assert_equal @cc.data, :month => 10, :year => 2014
  end

  def test_encrypt_field
    assert_equal @cc.data_encrypted, 'd3f1d84f75f95027af7697f59c07437508ec98377a6d4104c7d7dc79967bf46b'
  end

  def test_not_fail_with_nil
    @cc.data = nil
    @cc.save
    @cc.reload
    assert_nil @cc.data
  end
end
