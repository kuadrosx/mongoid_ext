require 'helper'

class TestVoteable < Minitest::Test
  def setup
    User.delete_all
    @user = User.create!(:login => "foo", :email => "foo@bar.baz")
  end

  def test_votes_average
    @user.vote!(1, "voter_id1")
    @user.vote!(1, "voter_id2")
    @user.vote!(-1, "voter_id3")

    @user.reload
    assert_equal @user.votes_average, 1
  end

  def test_votes_count
    @user.vote!(1, "voter_id1")
    @user.vote!(1, "voter_id2")
    @user.vote!(-1, "voter_id3")
    @user.vote!(-1, "voter_id4")

    @user.reload
    assert_equal @user.votes_count, 4
  end

  def test_one_vote_by_voter_id
    @user.vote!(1, "voter_id1")
    @user.vote!(1, "voter_id1")
    @user.vote!(1, "voter_id1")
    @user.reload
    assert_equal @user.votes_count, 1
  end

  def test_change_vote
    @user.vote!(1, "voter_id1")
    @user.vote!(-1, "voter_id1")

    @user.reload
    assert_equal @user.votes_count, 1
    assert_equal @user.votes_average, -1
  end

  def test_count_votes
    @user.vote!(1, "voter_id1")
    @user.vote!(1, "voter_id2")
    @user.vote!(-1, "voter_id3")
    @user.vote!(-1, "voter_id4")
    @user.vote!(-1, "voter_id5")

    @user.reload
    assert_equal @user.votes_average, -1
    assert_equal @user.votes_up, 2
    assert_equal @user.votes_down, 3
  end

  def test_voted?
    @user.vote!("1", "voter_id1")
    @user.vote!("1", "voter_id2")

    assert_equal @user.voted?("voter_id1"), true
    @user.reload
    assert_equal @user.voted?("voter_id1"), true
    assert_equal @user.voted?("voter_id3"), false
  end

  def test_voted_without_load_votes
    @user.vote!("1", "voter_id1")
    @user = User.without(:votes).find(@user.id)
    assert_equal @user.voted?("voter_id1"), true
    assert_equal @user.voted?("voter_id2"), false
  end

  def test_vote_on_embedded_models
    picture = @user.pictures.create(:title => "Mona Lisa")
    picture.vote!(1, "voter_id1")
    @user.reload
    assert_equal @user.pictures.first.votes_average, 1
  end
end
