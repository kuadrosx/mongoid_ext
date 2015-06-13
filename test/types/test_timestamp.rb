require 'helper'

class TimestampTest < Minitest::Test
  def from_db
    Event.find(@event.id)
  end

  def setup
    Event.delete_all

    Time.zone = 'UTC'
    @start_time = Time.zone.parse('01-01-2009')
    @end_time = @start_time.tomorrow

    @event = Event.create!(
      :start_date => @start_time.to_i,
      :end_date => @end_time.to_i
    )
  end

  def test_store_date
    assert_equal from_db.start_date.to_s, @start_time.to_s
  end

  def test_time_to_given_timezone
    Time.zone = 'Hawaii'
    assert_equal from_db.start_date.to_s, "2008-12-31 14:00:00 -1000"
  end

  def test_compare_dates
    start_time = @start_time.tomorrow.tomorrow
    end_time = start_time.tomorrow

    @event2 = Event.create!(:start_date => start_time.utc, :end_date => end_time.utc)

    assert_equal Event.count, 2
    events = Event.where("this.start_date >= %d && this.start_date <= %d" % [@event.start_date.yesterday.to_i, @event2.start_date.yesterday.to_i])

    assert_equal events, [@event]
  end
end
