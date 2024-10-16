# frozen_string_literal: true

# spec/controllers/api/v1/recipes_controller_spec.rb

require 'rails_helper'

RSpec.describe Api::V1::RecipesController do
  describe 'GET #search' do
    context 'when ingredients are provided' do
      let!(:pesto_pizza) { create(:pesto_pizza) }
      let!(:vegetarian_pasta) { create(:vegetarian_pasta) }

      before do
        create(:recipe_ingredient, recipe: pesto_pizza, ingredient: create(:ingredient, name: 'pesto'))
        create(:recipe_ingredient, recipe: pesto_pizza, ingredient: create(:ingredient, name: 'pita bread'))
        create(:recipe_ingredient, recipe: vegetarian_pasta, ingredient: create(:ingredient, name: 'couscous'))
        create(:recipe_ingredient, recipe: vegetarian_pasta, ingredient: create(:ingredient, name: 'almond'))
      end

      context 'with matching ingredients' do
        before { get :search, params: { ingredients: 'pesto,pita' } }

        it 'returns a successful response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the correct number of recipes' do
          json_response = response.parsed_body
          expect(json_response['recipes'].length).to eq(1)
        end

        it 'returns the correct recipe title' do
          json_response = response.parsed_body
          expect(json_response['recipes'][0]['title']).to eq('Pesto Pita Pizza')
        end
      end

      context 'with non-matching ingredients' do
        before { get :search, params: { ingredients: 'chocolate,strawberry' } }

        it 'returns a not found status' do
          expect(response).to have_http_status(:not_found)
        end

        it 'returns the correct error message' do
          json_response = response.parsed_body
          expect(json_response['error']).to eq('No recipes found')
        end
      end
    end

    context 'when ingredients are not provided' do
      before { get :search, params: { ingredients: '' } }

      it 'returns a bad request status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns the correct error message' do
        json_response = response.parsed_body
        expect(json_response['error']).to eq('Ingredients parameter is required')
      end
    end
  end
end
