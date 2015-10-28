require 'helper'

class TestTags < Minitest::Test
  def setup
    BlogPost.delete_all
    @blogpost = BlogPost.create(:title => "operation systems",
                                :body => "list of some operating systems",
                                :tags => %w(list windows freebsd osx linux))
    @blogpost2 = BlogPost.create(:title => "nosql database",
                                 :body => "list of some nosql databases",
                                 :tags => %w(list mongodb redis couchdb))
  end

  def test_generate_tagcloud
    cloud = BlogPost.tag_cloud

    [{ "name" => "list", "count" => 2.0 },
     { "name" => "windows", "count" => 1.0 },
     { "name" => "freebsd", "count" => 1.0 },
     { "name" => "osx", "count" => 1.0 },
     { "name" => "linux", "count" => 1.0 },
     { "name" => "mongodb", "count" => 1.0 },
     { "name" => "redis", "count" => 1.0 },
     { "name" => "couchdb", "count" => 1.0 }].each do |entry|
      assert_includes cloud, entry
    end
  end

  def test_find_with_tags
    assert_equal BlogPost.find_with_tags("mongodb").to_a, [@blogpost2]
    posts = BlogPost.find_with_tags("mongodb", "linux").to_a
    assert_includes posts, @blogpost
    assert_includes posts, @blogpost2
    assert_equal posts.count, 2
  end

  def test_find_with_tags_pattern
    tags = BlogPost.find_tags(/^li/)
    [{ "name" => "list", "count" => 2.0 }, { "name" => "linux", "count" => 1.0 }].each do |entry|
      assert_includes tags, entry
    end
    assert_equal tags.count, 2
  end
end
