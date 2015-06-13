require 'helper'

class TestSlugizer < Minitest::Test
  def setup
    BlogPost.delete_all
    @blogpost = BlogPost.create(:title => "%bLog pOSt tiTLe!",
                                :body => "HeRe is tHe Body of the bLog pOsT")
  end

  def test_generate_slug
    assert_match(/\w+-blog-post-title/, @blogpost.slug)
  end

  def test_not_generate_slug_when_slug_key_is_blank
    @empty_blogpost = BlogPost.new
    assert_nil @empty_blogpost.slug
  end

  def test_slug_as_param
    assert_match(/\w+-blog-post-title/, @blogpost.to_param)
  end

  def test_id_as_param_when_not_slug
    @blogpost.slug = nil
    assert_equal @blogpost.to_param, @blogpost.id.to_s
  end

  def test_max_length_option
    @blogpost = BlogPost.create(
      :title => "ultimo video/cancion en youtube?",
      :body => "HeRe is tHe Body of the bLog pOsT"
    )
    assert_match(/\w+-ultimo-video-canci/, @blogpost.slug)
  end

  def test_min_length_option
    @blogpost = BlogPost.create(
      :title => "a",
      :body => "HeRe is tHe Body of the bLog pOsT"
    )
    assert_nil @blogpost.slug
  end

  def test_update_slug_after_updating_object
    @blogpost = BlogPost.create(:title => "ultimo video/cancion en youtube?",
                                :body => "HeRe is tHe Body of the bLog pOsT")
    assert_match(/\w+-ultimo-video-canci/, @blogpost.slug)
    @blogpost.title = "primer video/cancion en youtube?"
    @blogpost.valid?
    assert_match(/\w+-primer-video-canci/, @blogpost.slug)
  end

  def test_find_by_slug
    assert_equal BlogPost.by_slug(@blogpost.slug), @blogpost
  end

  def test_find_by_id
    assert_equal BlogPost.by_slug(@blogpost.id), @blogpost
  end
end
