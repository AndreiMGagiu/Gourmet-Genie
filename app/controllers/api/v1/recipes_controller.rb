# frozen_string_literal: true

module Api
  module V1
    class RecipesController < BaseController
      before_action :validate_ingredients
      before_action :fetch_recipes

      # Returns recipes based on provided ingredients
      # @return [JSON] List of matching recipes with their dietary requirements
      def search
        render json: { recipes: }, status: :ok
      end

      private

      # Validates the presence of the ingredients parameter
      # Renders an unprocessable entity error if the ingredients parameter is missing
      # @return [void]
      def validate_ingredients
        render_unprocessable_entity(['Ingredients parameter is required']) if ingredients.empty?
      end

      # Fetches the matching recipes based on ingredients
      # Renders a not found error if no matching recipes are found
      # @return [void]
      def fetch_recipes
        render_not_found('No recipes found for the given ingredients') if match_recipes.empty?
      end

      # Retrieves the recipes matching the provided ingredients
      # @return [Array<Recipe>] Array of Recipe objects with dietary requirements included
      def match_recipes
        @match_recipes ||= Recipe.find_by_ingredients(ingredients).includes(:dietary_requirements)
      end

      # Builds the recipe data including dietary requirements for the response
      # @return [Array<Hash>] Array of hashes representing recipes with dietary requirements
      def recipes
        match_recipes.map do |recipe|
          recipe.as_json.merge(dietary_requirements: recipe.dietary_requirements.pluck(:name))
        end
      end

      # Splits and cleans the ingredients parameter
      # @return [Array<String>] Array of cleaned ingredient strings
      def ingredients
        @ingredients ||= params[:ingredients].to_s.split(',').map(&:strip).reject(&:empty?)
      end
    end
  end
end
