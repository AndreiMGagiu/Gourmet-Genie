# frozen_string_literal: true

module ImportService
  # Handles the import of ingredients for recipes.
  #
  # This class processes a given ingredient string, extracting the name,
  # quantity, and unit, and then saves the associated RecipeIngredient
  # record.
  class Ingredients
    MEASUREMENTS = YAML.load_file(Rails.root.join('config/ingredient_measurements.yml')).freeze

    # Initializes the Ingredients processor with a recipe and ingredient string.
    #
    # @param recipe [Recipe] The recipe associated with the ingredient.
    # @param ingredient_string [String] The ingredient string to be processed.
    def initialize(recipe, ingredient_string)
      @recipe = recipe
      @ingredient_string = ingredient_string.strip
      @components = @ingredient_string.split
    end

    # Imports the ingredient into the database and returns the RecipeIngredient instance.
    #
    # This method finds or initializes a RecipeIngredient record for the
    # given recipe and ingredient, then updates it with the extracted
    # quantity and unit. If an error occurs, it logs the error and raises it again.
    #
    # @return [RecipeIngredient] The RecipeIngredient record created or updated.
    def import
      ingredient = find_or_create_ingredient
      RecipeIngredient.find_or_initialize_by(recipe: @recipe, ingredient: ingredient).tap do |ri|
        ri.update(quantity: extract_quantity, unit: extract_unit)
      end
    rescue StandardError => error
      Rails.logger.error("Failed to import ingredient: #{@ingredient_string}, error: #{error.message}")
      raise
    end

    private

    # Finds or creates the ingredient associated with this instance.
    #
    # @return [Ingredient] The Ingredient record created or found.
    def find_or_create_ingredient
      Ingredient.find_or_create_by!(name: extract_name)
    end

    # Extracts the ingredient name from the ingredient string.
    #
    # @return [String] The name of the ingredient without quantity or unit.
    def extract_name
      @components.reject { |part| valid_quantity?(part) || valid_unit?(part) }.join(' ')
    end

    # Extracts the quantity from the ingredient string.
    #
    # @return [String, nil] The quantity of the ingredient, or nil if not found.
    def extract_quantity
      @components.find { |part| valid_quantity?(part) }
    end

    # Extracts the unit from the ingredient string.
    #
    # @return [String, nil] The unit of the ingredient, or nil if not valid.
    def extract_unit
      @components.find { |part| valid_unit?(part) }
    end

    # Checks if the given part is a valid quantity.
    #
    # @param part [String] The part of the ingredient string to check.
    # @return [Boolean] True if the part is a valid quantity, false otherwise.
    def valid_quantity?(part)
      part.match?(/^\d+(\.\d+)?$/) || part.match?(%r{^\d+/\d+$}) || MEASUREMENTS['quantities'].include?(part.downcase)
    end

    # Checks if the given part is a valid unit.
    #
    # @param part [String] The part of the ingredient string to check.
    # @return [Boolean] True if the part is a valid unit, false otherwise.
    def valid_unit?(part)
      singular = part.singularize
      plural = part.pluralize
      MEASUREMENTS['units'].include?(singular) || MEASUREMENTS['units'].include?(plural)
    end
  end
end
