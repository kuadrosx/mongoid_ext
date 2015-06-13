# encoding: utf-8
require 'helper'

class TestFilter < Minitest::Test
  def setup
    BlogPost.delete_all
    @blogpost = BlogPost.create!(:title => "%How dOEs tHIs Work?!",
                                 :body => "HeRe is tHe Body of the bLog pOsT",
                                 :tags => ["my", "list", "of", "tags"])
    @entradablog = BlogPost.create!(:title => "sobre las piña",
                                    :body => "la piña no es un árbol",
                                    :tags => ["frutas"])
  end

  def test_insensitive
    assert_equal BlogPost.filter("body"), [@blogpost]
  end

  def test_find_by_title
    assert_equal BlogPost.filter("this"), [@blogpost]
  end

  def test_find_by_body
    assert_equal BlogPost.filter("blog"), [@blogpost]
  end

  def test_find_by_tags
    assert_equal BlogPost.filter("list"), [@blogpost]
  end

  def test_by_title_or_body
    assert_equal BlogPost.filter("work blog"), [@blogpost]
  end

  def test_ignore_inexistant_words
    assert_equal BlogPost.filter("work lalala"), [@blogpost]
  end

  def test_normalize_the_text
    assert_equal BlogPost.filter("pina"), [@entradablog]
    assert_equal BlogPost.filter("arbol"), [@entradablog]
  end

  def test_paginate_results
    results = BlogPost.filter("tag", :per_page => 1, :page => 1)
    assert_equal results, [@blogpost]
    assert_equal results.total_pages, 1
  end
end
