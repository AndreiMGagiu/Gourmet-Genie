# frozen_string_literal: true

# Represents a category for recipes.
#
# A category is used to group recipes under a specific label, e.g: "Vegan",
# "Dessert",etc. Each category must have a unique name.
class Category < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :recipes, dependent: :destroy
end
