# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RecipeIngredientsController do
  describe 'GET #show' do
    let(:category) { create(:category, name: 'Main Course') }
    let(:user) { create(:user, name: 'John Doe') }
    let(:recipe) { create(:recipe, category: category, user: user) }
    let(:chicken) { create(:ingredient, name: 'Chicken') }
    let(:garlic) { create(:ingredient, name: 'Garlic') }
    let(:recipe_ingredient_chicken) do
      create(:recipe_ingredient, recipe: recipe, ingredient: chicken, quantity: '2', unit: 'pieces')
    end
    let(:recipe_ingredient_garlic) do
      create(:recipe_ingredient, recipe: recipe, ingredient: garlic, quantity: '5', unit: 'cloves')
    end
    let(:rating_john) { create(:rating, recipe: recipe, score: 5, user: user) }
    let(:rating_jane) { create(:rating, recipe: recipe, score: 4, user: create(:user, name: 'Jane Doe')) }

    context 'when the recipe exists' do
      before do
        recipe_ingredient_chicken
        recipe_ingredient_garlic
        rating_john
        rating_jane
        get :show, params: { id: recipe.id }
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct recipe category' do
        json_response = response.parsed_body
        expect(json_response['category']).to eq('Main Course')
      end

      it 'returns the correct number of ingredients' do
        json_response = response.parsed_body
        expect(json_response['ingredients'].length).to eq(2)
      end

      it 'returns the correct ingredients' do
        json_response = response.parsed_body
        expect(json_response['ingredients']).to include(
          { 'name' => 'Chicken', 'quantity' => '2', 'unit' => 'pieces' },
          { 'name' => 'Garlic', 'quantity' => '5', 'unit' => 'cloves' }
        )
      end

      it 'returns the correct ratings' do
        json_response = response.parsed_body
        expect(json_response['ratings']).to include(
          { 'score' => 5, 'user_name' => 'John Doe' },
          { 'score' => 4, 'user_name' => 'Jane Doe' }
        )
      end

      it 'returns the correct average rating' do
        json_response = response.parsed_body
        expect(json_response['average_rating']).to eq(4.5)
      end
    end

    context 'when the recipe does not exist' do
      it 'returns a not_found status' do
        get :show, params: { id: 'nonexistent-id' }
        expect(response).to have_http_status(:not_found)
      end

      it 'returns the correct error message' do
        get :show, params: { id: 'nonexistent-id' }
        json_response = response.parsed_body
        expect(json_response['error']).to eq('Recipe not found')
      end
    end
  end
end
