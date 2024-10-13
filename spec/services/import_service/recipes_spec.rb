# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportService::Recipes do
  subject(:imported_recipe) { described_class.new(data).import }

  let(:data) do
    {
      'title' => 'Golden Sweet Cornbread',
      'cook_time' => 25,
      'prep_time' => 10,
      'ingredients' => [
        '1 cup all-purpose flour',
        '1 cup yellow cornmeal',
        '⅔ cup white sugar',
        '1 teaspoon salt',
        '3 ½ teaspoons baking powder',
        '1 egg',
        '1 cup milk',
        '⅓ cup vegetable oil'
      ],
      'ratings' => 4.74,
      'cuisine' => '',
      'category' => 'Cornbread',
      'author' => 'bluegirl',
      'image' => 'https://example.com/cornbread.jpg'
    }
  end

  describe '#import' do
    context 'when importing a new recipe' do
      it 'creates a new recipe' do
        expect { imported_recipe }.to change(Recipe, :count).by(1)
      end

      it 'sets the correct attributes for the recipe' do
        expect(imported_recipe).to have_attributes(
          title: 'Golden Sweet Cornbread',
          cook_time: 25,
          prep_time: 10,
          user: an_instance_of(User),
          category: an_instance_of(Category)
        )
      end
    end

    context 'when the recipe already exists' do
      let!(:existing_recipe) do
        create(:recipe, title: 'Golden Sweet Cornbread', user: create(:user, name: 'bluegirl'),
          category: create(:category, name: 'Cornbread'), cook_time: 54, prep_time: 12)
      end

      it 'does not create a new recipe' do
        expect { imported_recipe }.not_to change(Recipe, :count)
      end

      it 'updates the existing recipe with correct attributes' do
        imported_recipe.reload
        expect(existing_recipe.reload).to have_attributes(cook_time: 25, prep_time: 10)
      end
    end

    context 'when importing ingredients' do
      it 'creates recipe ingredients for the recipe' do
        expect { imported_recipe }.to change(RecipeIngredient, :count).by(8)
      end

      it 'correctly imports the first ingredient attributes' do
        ingredient = imported_recipe.recipe_ingredients.find { |ri| ri.ingredient.name == 'all-purpose flour' }
        expect(ingredient).to have_attributes(quantity: '1', unit: 'cup')
      end
    end

    context 'when importing a rating' do
      it 'creates a rating for the recipe' do
        expect { imported_recipe }.to change(Rating, :count).by(1)
      end

      it 'sets the correct rating score' do
        expect(imported_recipe.ratings.first.score).to eq(5)
      end
    end

    context 'when a RecordNotUnique error occurs' do
      let(:error) { ActiveRecord::RecordNotUnique.new('Record already exists') }

      before do
        allow(Recipe).to receive(:find_or_initialize_by).and_raise(error)
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the RecordNotUnique error' do
        expect do
          imported_recipe
        end.to raise_error(ActiveRecord::RecordNotUnique)

        expect(Rails.logger).to have_received(:error).with(/Failed to import recipe:/)
      end

      it 're-raises the RecordNotUnique error' do
        expect { imported_recipe }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
