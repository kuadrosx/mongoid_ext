require 'helper'

class TestParanoia < Minitest::Test
  def setup
    User.delete_all
    User.deleted.delete_all

    @user = User.create(
      :login => "foo",
      :email => "foo@bar.baz"
    )
  end

  def test_not_delete_permanently
    @user.destroy
    assert_equal User.deleted.count, 1
    assert_equal User.count, 0
  end

  def test_delete_permanently
    @user.destroy
    assert_equal User.deleted.count, 1
    assert_equal User.count, 0
    @user.destroy!
    assert_equal User.deleted.count, 0
  end

  def test_restore_deleted_record
    @user.destroy
    assert_equal User.deleted.first.restore.email, "foo@bar.baz"
  end

  def test_delete_old_records
    @user.destroy
    deleted = User.deleted.first
    deleted.created_at = 2.months.ago
    deleted.save

    User.deleted.compact!
    assert_equal User.deleted.count, 0
  end

  def test_find_record_using_original_id
    id = @user.id
    @user.destroy
    assert_equal User.deleted.find(id).nil?, false
  end
end
