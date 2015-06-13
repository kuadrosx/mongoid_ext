require 'helper'

class TestRandom < Minitest::Test
  def setup
  end

  def test_find_random_entry
    refute_nil Entry.random
    refute_nil Entry.random
    refute_nil Entry.random
  end

  def test_increment_counter
    entry = Entry.random
    assert_operator entry._random_times, :>, 0
  end

  def test_passing_conditions
    entry = Entry.random(:v => 10)
    assert_equal entry.v, 10
  end
end
