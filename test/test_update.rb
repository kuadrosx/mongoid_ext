require 'helper'

class UpdateTest < Minitest::Test
  def test_safe_update
    event = Event.new(:password => "original")
    start_date = Time.zone.now
    end_date = start_date.tomorrow

    event.safe_update(
      %w(start_date end_date),         "start_date" => start_date,
                                       "end_date" => end_date,
                                       "password" => "hacked"
    )
    assert_equal event.password, "original"
    assert_equal event.start_date.to_s, start_date.to_s
    assert_equal event.end_date.to_s, end_date.to_s
  end
end
