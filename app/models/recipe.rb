# frozen_string_literal: true

# Represents a recipe in the application.
#
# A recipe is a set of instructions used for preparing and cooking food. It is associated
# with a category and an author, and includes details such as title, cook time, and prep time.
class Recipe < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_dietary_requirements, dependent: :destroy
  has_many :dietary_requirements, through: :recipe_dietary_requirements

  validates :title, presence: true
  validates :cook_time, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :prep_time, numericality: { greater_than_or_equal_to: 0, allow_nil: false }

  scope :by_cuisine, ->(cuisine) { where(cuisine: cuisine) }
  scope :quick_recipes, -> { where('cook_time <= ? AND prep_time <= ?', 30, 15) }

  # Finds recipes that can be prepared with given time constraint
  #
  # @param minutes [Integer] The maximum total time available
  # @return [ActiveRecord::Relation] Recipes that can be prepared within the given time
  def self.preparable_within(minutes)
    where('cook_time <= ? AND prep_time <= ?', minutes, minutes)
  end
end
