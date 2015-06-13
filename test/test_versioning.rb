require 'helper'

class TestVersioning < Minitest::Test
  def setup
    BlogPost.delete_all
    User.delete_all

    @blogpost = BlogPost.create!(
      :title => "operating systems",
      :body => "list of some operating systems",
      :tags => %w[list windows freebsd osx linux],
      :updated_by => User.create(:login => "foo")
    )
  end

  def test_generate_new_version
    assert_equal @blogpost.versions_count, 0
    @blogpost.title = "sistemas operativos"
    @blogpost.save!
    @blogpost.reload
    assert_equal @blogpost.versions_count, 1
  end

  def test_generate_diff_between_versions
    @blogpost.title = "sistemas operativos"
    @blogpost.save!
    @blogpost.reload
    assert_equal @blogpost.diff_by_word(:title, "current", 0, :ascii), "{\"operating\" >> \"sistemas\"} {\"systems\" >> \"operativos\"}"
    assert_equal @blogpost.diff_by_line(:title, 0, "current", :ascii), "{\"sistemas operativos\" >> \"operating systems\"}"
  end

  def test_restore_previous_version
    @blogpost.title = "sistemas operativos"
    @blogpost.save!
    @blogpost.reload

    assert_equal @blogpost.title, "sistemas operativos"
    @blogpost.rollback!(0)
    assert_equal @blogpost.title, "operating systems"
  end

  def test_versions_limit_option
    @blogpost.title = "sistemas operativos"
    @blogpost.save!
    @blogpost.reload
    @blogpost.title = "sistemas operativos 2"
    @blogpost.save!
    @blogpost.reload
    @blogpost.title = "sistemas operativos 3"
    @blogpost.save!
    @blogpost.reload

    assert_equal @blogpost.versions.count, 2
  end
end
