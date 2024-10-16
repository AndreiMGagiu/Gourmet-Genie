# frozen_string_literal: true

module Api
  module V1
    class RecipeIngredientsController < ApplicationController
      before_action :set_recipe, only: [:show]

      rescue_from ActiveRecord::RecordNotFound, with: :render_recipe_not_found

      # GET /api/v1/recipes/:id/ingredients
      #
      # Fetches the ingredients, category, and ratings for a specific recipe.
      #
      # @return [JSON] A JSON response containing recipe ingredients, category, ratings, and average rating.
      def show
        render json: recipe_details_response, status: :ok
      end

      private

      # Sets the @recipe instance variable by finding the recipe by ID.
      #
      # @raise [ActiveRecord::RecordNotFound] If the recipe with the given ID is not found.
      def set_recipe
        @recipe = Recipe.includes(:category, :recipe_ingredients, :ingredients, ratings: :user).find(params[:id])
      end

      # Prepares the response data for the recipe details
      #
      # @return [Hash] A hash containing ingredients, category, ratings, and average rating.
      def recipe_details_response
        {
          ingredients: formatted_ingredients,
          category: @recipe.category.name,
          ratings: formatted_ratings,
          average_rating: @recipe.average_rating
        }
      end

      # Formats the recipe ingredients for the JSON response
      #
      # @return [Array<Hash>] Array of ingredients with names, quantities, and units.
      def formatted_ingredients
        @recipe.recipe_ingredients.map do |ri|
          {
            name: ri.ingredient.name,
            quantity: ri.quantity,
            unit: ri.unit
          }
        end
      end

      # Formats the recipe ratings for the JSON response
      #
      # @return [Array<Hash>] Array of ratings with scores and user names.
      def formatted_ratings
        @recipe.ratings.map do |rating|
          {
            score: rating.score,
            user_name: rating.user.name
          }
        end
      end

      # Renders a 404 response if the recipe is not found.
      #
      # @return [JSON] The error response with a 404 status code.
      def render_recipe_not_found
        render json: { error: 'Recipe not found' }, status: :not_found
      end
    end
  end
end
