require 'helper'

class TestVersioning < Minitest::Test
  def setup
    BlogPost.delete_all
    User.delete_all

    @blogpost = BlogPost.create!(
      :title => "operating systems",
      :body => "list of some operating systems",
      :tags => %w(list windows freebsd osx linux),
      :updated_by => User.create(:login => "foo")
    )
  end

  def change_three_times
    @blogpost.title = "sistemas operativos"
    @blogpost.save!
    @blogpost.reload
    @blogpost.title = "sistemas operativos 2"
    @blogpost.save!
    @blogpost.reload
    @blogpost.title = "sistemas operativos 3"
    @blogpost.save!
    @blogpost.reload
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
    assert_equal @blogpost.diff(:title, "current", 0, :ascii), "{\"operating systems\" >> \"sistemas operativos\"}"
    assert_equal @blogpost.diff_by_word(:title, "current", 0, :ascii), "{\"operating\" >> \"sistemas\"} {\"systems\" >> \"operativos\"}"
    assert_equal @blogpost.diff_by_line(:title, 0, "current", :ascii), "{\"sistemas operativos\" >> \"operating systems\"}"
    assert_equal @blogpost.diff_by_char(:title, 0, "current", :ascii), "{-\"sistemas \"}operati{\"vo\" >> \"ng \"}s{+\"ystems\"}"
  end

  def test_restore_previous_version
    @blogpost.title = "sistemas operativos"
    @blogpost.save!
    @blogpost.reload

    assert_equal @blogpost.title, "sistemas operativos"
    @blogpost.rollback!(0)
    assert_equal @blogpost.title, "operating systems"
  end

  def test_load_version
    @blogpost.title = "sistemas operativos"
    @blogpost.save!
    @blogpost.reload

    assert_equal @blogpost.title, "sistemas operativos"
    @blogpost.load_version(0)
    assert_equal @blogpost.title, "operating systems"
    assert_equal @blogpost.changed?, true
  end

  def test_version_at
    change_three_times
    assert_equal @blogpost.version_at("first").data[:title], "sistemas operativos"
    assert_equal @blogpost.version_at("last").data[:title], "sistemas operativos 2"
  end

  def test_version_content
    @blogpost.title = "sistemas operativos"
    @blogpost.save!
    @blogpost.reload

    assert_equal @blogpost.version_at('first').content(:tags), "list windows freebsd osx linux"
    assert_equal @blogpost.version_at('first').content(:title), "operating systems"
  end

  def test_versions_limit_option
    change_three_times
    assert_equal @blogpost.versions.count, 2
  end

  def test_owner_field_validation
    assert_raises ArgumentError do
      Class.new do
        include Mongoid::Document
        include MongoidExt::Versioning

        field :title, :type => String
        versionable_keys :title, :body, :tags, :owner_field => "not_found"
      end
    end
  end
end
