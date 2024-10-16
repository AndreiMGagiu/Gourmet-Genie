# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::RecipesController do
  describe 'GET #search' do
    let(:app) { create(:app) }

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
        before do
          request.headers['AppToken'] = app.secret_token
          get :search, params: { ingredients: 'pesto,pita' }
        end

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
        before do
          request.headers['AppToken'] = app.secret_token
          get :search, params: { ingredients: 'chocolate,strawberry' }
        end

        it 'returns a not found status' do
          expect(response).to have_http_status(:not_found)
        end

        it 'returns the correct error message' do
          json_response = response.parsed_body
          expect(json_response['error']).to eq('Not found')
        end
      end
    end

    context 'when ingredients are not provided' do
      before do
        request.headers['AppToken'] = app.secret_token
        get :search, params: { ingredients: '' }
      end

      it 'returns a bad request status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
