# frozen_string_literal: true

module Api
  module V1
    class RecipesController < BaseController
      # GET /api/v1/recipes/search
      #
      # Searches for recipes based on the provided ingredients.
      #
      # @return [JSON] A JSON response containing matching recipes or an error message.
      def search
        return render_unprocessable_entity(['Ingredients parameter is required']) if ingredients.empty?

        if recipes.present?
          render json: { recipes: recipes }, status: :ok
        else
          render_not_found('Not found')
        end
      end

      private

      # Retrieve recipes based on ingredients.
      #
      # @return [ActiveRecord::Relation] The filtered list of recipes.
      def recipes
        @recipes ||= Recipe.find_by_ingredients(ingredients) # Update query as necessary
      end

      # Extract and clean ingredients from the request params.
      #
      # @return [Array<String>] Cleaned ingredient strings.
      def ingredients
        @ingredients ||= params[:ingredients].to_s.split(',').map(&:strip).reject(&:empty?)
      end
    end
  end
end
