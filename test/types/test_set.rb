require 'helper'

class SetTest < Minitest::Test
  def from_db
    Recipe.find(@recipe.id)
  end

  def setup
    @recipe = Recipe.new
    @recipe.ingredients = Set.new(%w(salt sugar water salt sugar water))
    @recipe.save
  end

  def test_not_duplicates
    assert_equal from_db.ingredients.size, 3
    assert_includes from_db.ingredients, "salt"
    assert_includes from_db.ingredients, "sugar"
    assert_includes from_db.ingredients, "water"
  end

  def test_not_add_duplicates
    original_size = @recipe.ingredients.size
    @recipe.ingredients << "salt"
    @recipe.save
    @recipe.reload

    assert_equal @recipe.ingredients.size, original_size
  end
end
