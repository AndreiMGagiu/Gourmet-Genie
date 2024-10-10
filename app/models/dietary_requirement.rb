# frozen_string_literal: true

# Represents a dietary requirement in the recipe system.
# This model is used to categorize recipes based on dietary restrictions or preferences.
#
# @attr [String] name The name of the dietary requirement (e.g., "Vegetarian", "Gluten-Free")
#
# @return [ActiveRecord::Associations::CollectionProxy<Recipe>] The recipes associated with this dietary requirement
class DietaryRequirement < ApplicationRecord
  has_many :recipe_dietary_requirements, dependent: :destroy

  has_many :recipes, through: :recipe_dietary_requirements

  validates :name, presence: true, uniqueness: true
end
