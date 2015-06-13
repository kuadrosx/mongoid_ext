require 'helper'

class StorageTest < Minitest::Test
  def setup
    @avatar = Avatar.create
    @data = StringIO.new("my avatar image")
    @new_avatar = Avatar.new
  end

  def test_store_file
    @avatar.put_file("an_avatar.png", @data)
    @avatar.save
    avatar = Avatar.find(@avatar.id)
    data = avatar.fetch_file("an_avatar.png").data
    assert_equal data, "my avatar image"
  end

  def test_not_close_the_file_after_storing
    @avatar.put_file("an_avatar.png", @data)
    assert_predicate @data, :closed?
  end

  def test_store_a_given_file
    @avatar.data = @data
    @avatar.save!

    refute_nil @avatar.data, nil
    assert_equal @avatar.data.data, "my avatar image"
  end

  def test_store_data_correctly
    @avatar.data = @data
    @avatar.save
    @avatar = Avatar.find(@avatar.id)
    assert_equal @avatar.data.data, "my avatar image"
  end

  def store_file_after_saving
    @new_avatar.put_file("an_avatar.png", @data)
    @new_avatar.save
    assert_equal @new_avatar.fetch_file("an_avatar.png").data, "my avatar image"
  end

  def test_not_store_file_with_permanent_object
    @avatar.put_file("an_avatar.png", @data)
    assert_nil @avatar.fetch_file("an_avatar.png").data
  end

  def teardown
    @alternative.close if @alternative
  end

  def setup_alternative
    @avatar = Avatar.new
    @alternative = File.new(__FILE__)
    @data = File.read(__FILE__)
  end

  def test_store_file_in_list
    setup_alternative
    @avatar.first_alternative = @alternative
    @avatar.save
    fromdb = @avatar.reload
    assert_equal fromdb.first_alternative.data, @data
  end

  def test_store_file_in_alternative_list
    @avatar.alternatives.put("an_alternative", @alternative)
    @avatar.save
    @avatar.reload
    assert_equal @avatar.alternatives.get("an_alternative").data, @data
  end

  def test_fetch_list_of_files
    [1,2,3].each do |n|
      @avatar.put_file("file#{n}", StringIO.new("data#{n}"))
    end
    file_names = @avatar.files.map { |f| f.filename }
    assert_equal file_names.size, 3
    [1,2,3].each do |n|
      assert_includes file_names, "file#{n}"
    end
  end

  def test_iterate_list_of_files
    [1,2,3].each do |n|
      @avatar.put_file("file#{n}", StringIO.new("data#{n}"))
    end

    file_names = %w[file1 file2 file3]
    @avatar.file_list.each_file do |key, file|
      assert_includes file_names, key
      assert_includes file_names, file.filename
    end
  end
end
