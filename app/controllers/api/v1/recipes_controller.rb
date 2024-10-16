# frozen_string_literal: true

module Api
  module V1
    class RecipesController < ApplicationController
      # GET /api/v1/recipes/search
      #
      # Searches for recipes based on the provided ingredients.
      #
      # @return [JSON] A JSON response containing matching recipes or an error message.
      def search
        return render_error('Ingredients parameter is required', :bad_request) if ingredients.empty?

        if recipes.present?
          render json: { recipes: recipes }, status: :ok
        else
          render_error('No recipes found', :not_found)
        end
      end

      private

      # Retrieve recipes based on ingredients.
      #
      # @return [ActiveRecord::Relation] The filtered list of recipes.
      def recipes
        @recipes ||= Recipe.find_by_ingredients(ingredients)
      end

      # Extract and clean ingredients from the request params.
      #
      # @return [Array<String>] Cleaned ingredient strings.
      def ingredients
        @ingredients ||= params[:ingredients].to_s.split(',').map(&:strip).reject(&:empty?)
      end

      # Render an error message with the specified status.
      #
      # @param message [String] The error message to display.
      # @param status [Symbol] The HTTP status to return.
      # @return [JSON] The error response with the provided message and status.
      def render_error(message, status)
        render json: { error: message }, status: status
      end
    end
  end
end
