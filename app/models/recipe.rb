# frozen_string_literal: true

# Recipe model handles recipe data, associations, and related logic.
# It includes methods to search for recipes by ingredients using similarity matching
# and to calculate average ratings.
#
class Recipe < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_dietary_requirements, dependent: :destroy
  has_many :dietary_requirements, through: :recipe_dietary_requirements
  has_many :ratings, dependent: :destroy

  validates :title, presence: true
  validates :cook_time, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :prep_time, numericality: { greater_than_or_equal_to: 0, allow_nil: false }

  scope :by_cuisine, ->(cuisine) { where(cuisine: cuisine) }
  scope :quick_recipes, -> { where('cook_time <= ? AND prep_time <= ?', 30, 15) }

  # Find recipes by ingredient names with optimized querying.
  # This method normalizes the provided ingredients (singularizes, downcases, strips)
  # and uses the pg_trgm extension to search for recipes whose ingredients
  # match the provided list with a similarity threshold.
  #
  # @param [Array<String>] ingredients the ingredients to search for
  # @param [Float] similarity_threshold the minimum similarity required (default is 0.2)
  # @return [ActiveRecord::Relation] the filtered list of recipes matching the ingredients
  def self.find_by_ingredients(ingredients, similarity_threshold: 0.2)
    return none if ingredients.blank?

    normalized_ingredients = normalize_ingredients(ingredients)

    joins(:ingredients)
      .where(build_similarity_conditions(normalized_ingredients, similarity_threshold), *normalized_ingredients)
      .group('recipes.id')
      .select('recipes.*, COUNT(DISTINCT ingredients.id) AS matching_ingredients_count')
      .order('matching_ingredients_count DESC')
      .includes(:category, :user)
  end

  # Normalize ingredient names by downcasing, stripping, and singularizing.
  # Sanitizes SQL inputs to prevent SQL injection.
  #
  # @param [Array<String>] ingredients list of ingredient names
  # @return [Array<String>] normalized ingredient names
  def self.normalize_ingredients(ingredients)
    ingredients.map { |name| sanitize_sql_like(name.downcase.strip.singularize) }
  end

  # Dynamically builds similarity conditions for SQL query.
  # This creates SQL fragments to compare ingredients using SIMILARITY
  # based on the provided ingredients and threshold.
  #
  # @param [Array<String>] ingredients list of normalized ingredient names
  # @param [Float] threshold the similarity threshold for matching (e.g., 0.2)
  # @return [String] the SQL fragment for the similarity condition
  def self.build_similarity_conditions(ingredients, threshold)
    ingredients.map { "SIMILARITY(LOWER(ingredients.name), ?) > #{threshold}" }.join(' OR ')
  end

  # Calculates the average rating for the recipe.
  # If no ratings are available, returns 0.0.
  #
  # @return [Float] The average rating of the recipe, rounded to two decimal places.
  def average_rating
    ratings.average(:score).to_f.round(2)
  end

  # Finds recipes that can be prepared with given time constraint.
  #
  # @param minutes [Integer] The maximum total time available
  # @return [ActiveRecord::Relation] Recipes that can be prepared within the given time
  def self.preparable_within(minutes)
    where('cook_time <= ? AND prep_time <= ?', minutes, minutes)
  end
end
