require 'helper'

class ModifiersTest < Minitest::Test

  def setup
    @entry = Entry.create(:v => 345)
  end

  def test_increment_value
    Entry.increment({:_id => @entry.id}, {:v => 1})
    @entry.reload
    assert_equal @entry.v, 346
  end

  def test_decrement_value
    @entry.decrement(:v => 1)
    @entry.reload
    assert_equal @entry.v, 344
  end

  def test_override_value
    @entry.override(:v => 543)
    @entry.reload
    assert_equal @entry.v, 543
  end

  def test_unset_value
    @entry.unset(:v => true)
    @entry.reload
    assert_equal @entry.v, nil
  end

  def test_push_value
    @entry.push(:a => 1)
    @entry.reload
    assert_equal @entry.a, [1]
  end

  def test_push_not_duplicate_value
    @entry.push_uniq(:a => 1)
    @entry.push_uniq(:a => 1)
    @entry.push_uniq(:a => 1)
    @entry.reload
    assert_equal @entry.a, [1]
  end

  def test_pull_value
    @entry.push_uniq(:a => 1)
    @entry.push_uniq(:a => 2)
    @entry.push_uniq(:a => 3)
    @entry.pull(:a => 2)
    @entry.reload
    assert_equal @entry.a, [1, 3]
  end

  def test_pop_value
    @entry.push_uniq(:a => 1)
    @entry.push_uniq(:a => 2)
    @entry.push_uniq(:a => 3)
    @entry.pop(:a => 1)
    @entry.reload
    assert_equal @entry.a, [1, 2]
  end
end
