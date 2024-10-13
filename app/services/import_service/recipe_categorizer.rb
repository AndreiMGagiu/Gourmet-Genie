# frozen_string_literal: true

module ImportService
  # Responsible for determining the category of a recipe based on its title and ingredients.
  # The class uses both cooking methods (e.g., 'Slow Cooker') and keyword matching to determine
  # the most suitable category for the given recipe data. If no clear category can be determined,
  # it assigns the category as 'Uncategorized'.
  class RecipeCategorizer
    # Initializes the RecipeCategorizer with the recipe data.
    #
    # @param [Hash] recipe_data The data of the recipe, including its title and ingredients.
    def initialize(recipe_data)
      @recipe_data = recipe_data
    end

    # Finds or creates a category for the recipe based on the provided data.
    # It uses both the recipe title and ingredients to determine the most suitable category.
    # If no clear category is determined, it assigns 'Uncategorized'.
    #
    # @return [Category] The found or newly created Category record.
    def find_or_create
      Category.find_or_create_by!(name: determine_category)
    end

    # Determines the best category for the recipe by first trying to match cooking methods, and then
    # falling back to keyword matches in the recipe's title and ingredients. If no suitable category is found,
    # it defaults to 'Uncategorized'.
    #
    # @return [String] The determined category name or 'Uncategorized' if no match is found.
    def determine_category
      categorize_by_method_or_keywords || 'Uncategorized'
    end

    private

    attr_reader :recipe_data

    # Retrieves the downcased title of the recipe.
    #
    # @return [String] The recipe's title in lowercase.
    def recipe_title
      @recipe_title ||= recipe_data['title'].downcase
    end

    # Retrieves the ingredients of the recipe, all converted to lowercase for consistency.
    #
    # @return [Array<String>] A list of ingredients, all downcased.
    def recipe_ingredients
      @recipe_ingredients ||= recipe_data['ingredients'].map(&:downcase)
    end

    # Attempts to categorize the recipe either by matching cooking methods or by keyword scoring.
    # It first checks if a cooking method (like 'Slow Cooker') can be determined from the recipe,
    # and if that fails, it falls back on keyword matching.
    #
    # @return [String, nil] The category name or nil if no category was found.
    def categorize_by_method_or_keywords
      categorize_by_cooking_method || categorize_by_keywords
    end

    # Uses keyword matching to assign a category to the recipe. It calculates scores for each category
    # based on keyword occurrences in the title and ingredients. The category with the highest score is chosen,
    # but if the difference between the top two categories is small (less than 2 points), it returns nil to avoid ambiguity.
    #
    # @return [String, nil] The best-matching category, or nil if scores are too close or no match is found.
    def categorize_by_keywords
      scores = calculate_category_scores
      top_categories = scores.max_by(2) { |_, score| score }

      return nil if top_categories.first[1].zero?
      return nil if (top_categories.first[1] - top_categories.last[1]).abs < 2

      top_categories.first[0]
    end

    # Calculates the total score for each category by summing the relevance of its associated keywords
    # against the recipe's title and ingredients. Each keyword match contributes to the score of its category.
    #
    # @return [Hash<String, Integer>] A hash where the keys are category names and the values are their total scores.
    def calculate_category_scores
      category_rules.transform_values do |keywords|
        keywords.sum { |keyword| calculate_keyword_score(keyword) }
      end
    end

    # Computes the score for a specific keyword by evaluating how well it matches the recipe's title and ingredients.
    # An exact match in the title is worth 3 points, a partial match in the title is worth 2 points, and matches in
    # the ingredients can add 1 or 0.5 points.
    #
    # @param [String] keyword The keyword to evaluate against the recipe.
    # @return [Integer] The score for the keyword (0-3 points).
    def calculate_keyword_score(keyword)
      score_from_title(keyword) + score_from_ingredients(keyword)
    end

    # Assigns a score for the keyword based on its match in the recipe's title.
    # Exact matches contribute 3 points, while partial matches (the keyword appears but not as an exact word) contribute 2 points.
    #
    # @param [String] keyword The keyword to search for in the recipe title.
    # @return [Integer] The score for the keyword (0-3 points).
    def score_from_title(keyword)
      return 3 if exact_match?(keyword, recipe_title)
      return 2 if partial_match?(keyword, recipe_title)

      0
    end

    # Assigns a score for the keyword based on its match in the recipe's ingredients.
    # Exact matches in any ingredient contribute 1 point, while partial matches contribute 0.5 points.
    #
    # @param [String] keyword The keyword to search for in the recipe ingredients.
    # @return [Integer] The score for the keyword (0-1 points).
    def score_from_ingredients(keyword)
      recipe_ingredients.sum do |ingredient|
        if exact_match?(keyword, ingredient)
          1
        elsif partial_match?(keyword, ingredient)
          0.5
        else
          0
        end
      end
    end

    # Determines whether the keyword is an exact match with any word in the given text.
    # For example, the keyword 'bread' would be an exact match in 'banana bread'.
    #
    # @param [String] keyword The keyword to search for.
    # @param [String] text The text to search within.
    # @return [Boolean] True if the keyword exactly matches a word in the text, otherwise false.
    def exact_match?(keyword, text)
      text.split.include?(keyword)
    end

    # Determines whether the keyword partially matches a word in the given text. For example,
    # the keyword 'bread' would be a partial match in 'breadsticks'.
    #
    # @param [String] keyword The keyword to search for.
    # @param [String] text The text to search within.
    # @return [Boolean] True if the keyword partially matches a word in the text, otherwise false.
    def partial_match?(keyword, text)
      text.include?(keyword) && !exact_match?(keyword, text)
    end

    # Tries to categorize the recipe by detecting a recognized cooking method (such as 'Slow Cooker').
    # It searches for the cooking method in both the title and the ingredients.
    #
    # @return [String, nil] The name of the cooking method, capitalized as a category name, or nil if no match is found.
    def categorize_by_cooking_method
      cooking_methods.find do |method|
        return method.split.map(&:capitalize).join(' ') if match_found?(method)
      end
    end

    # Checks whether the given cooking method is present in either the recipe's title or its ingredients.
    #
    # @param [String] method The cooking method to look for.
    # @return [Boolean] True if the method is found in the title or ingredients, otherwise false.
    def match_found?(method)
      recipe_title.include?(method) || recipe_ingredients.any? { |ingredient| ingredient.include?(method) }
    end

    # Loads the category data from a YAML configuration file that contains categories and cooking methods.
    #
    # @return [Hash] The loaded configuration data.
    def category_data
      @category_data ||= YAML.load_file(Rails.root.join('config/category_rules.yml'))
    end

    # Retrieves the category rules, which define keywords for each category.
    #
    # @return [Hash<String, Array<String>>] A hash of categories and their associated keywords.
    def category_rules
      @category_rules ||= category_data['categories'].freeze
    end

    # Retrieves the recognized cooking methods from the configuration file.
    #
    # @return [Array<String>] A list of recognized cooking methods.
    def cooking_methods
      @cooking_methods ||= category_data['cooking_methods'].freeze
    end
  end
end
