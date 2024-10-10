# frozen_string_literal: true

# Represents an ingredient used in recipes.
class Ingredient < ApplicationRecord
  has_many :recipe_ingredients
  has_many :recipes, through: :recipe_ingredients

  validates :name, presence: true, uniqueness: true
end
