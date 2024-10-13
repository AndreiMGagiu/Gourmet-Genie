# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportService::Ingredients do
  let(:recipe) { create(:recipe) }
  let(:ingredient_string) { '2 cups all-purpose flour' }
  let(:service) { described_class.new(recipe, ingredient_string) }

  describe '#import' do
    subject(:import) { service.import }

    context 'when the ingredient does not exist' do
      it 'creates a new ingredient' do
        expect { import }.to change(Ingredient, :count).by(1)
      end

      it 'creates a new recipe_ingredient' do
        expect { import }.to change(RecipeIngredient, :count).by(1)
      end

      it 'sets the correct quantity' do
        expect(import.quantity).to eq('2')
      end

      it 'sets the correct unit' do
        expect(import.unit).to eq('cups')
      end

      it 'sets the correct ingredient name' do
        expect(import.ingredient.name).to eq('all-purpose flour')
      end
    end

    context 'when the ingredient exists but recipe_ingredient does not' do
      let!(:existing_ingredient) { create(:ingredient, name: 'all-purpose flour') }

      it 'does not create a new ingredient' do
        expect { import }.not_to change(Ingredient, :count)
      end

      it 'creates a new recipe_ingredient' do
        expect { import }.to change(RecipeIngredient, :count).by(1)
      end

      it 'associates with the existing ingredient' do
        expect(import.ingredient).to eq(existing_ingredient)
      end
    end

    context 'when the recipe_ingredient already exists' do
      let!(:existing_ingredient) { create(:ingredient, name: 'all-purpose flour') }
      let!(:existing_recipe_ingredient) do
        create(:recipe_ingredient, recipe: recipe, ingredient: existing_ingredient, quantity: '1', unit: 'cup')
      end

      it 'does not create a new recipe_ingredient' do
        expect { import }.not_to change(RecipeIngredient, :count)
      end

      it 'updates the existing recipe_ingredient quantity' do
        expect { import }.to change { existing_recipe_ingredient.reload.quantity }.from('1').to('2')
      end

      it 'updates the existing recipe_ingredient unit' do
        expect { import }.to change { existing_recipe_ingredient.reload.unit }.from('cup').to('cups')
      end
    end

    context 'with various ingredient formats' do
      {
        '1/2 cup sugar' => { quantity: '1/2', unit: 'cup', name: 'sugar' },
        '3 large eggs' => { quantity: '3', unit: nil, name: 'large eggs' },
        'salt to taste' => { quantity: nil, unit: nil, name: 'salt to taste' },
        '2.5 ml vanilla extract' => { quantity: '2.5', unit: 'ml', name: 'vanilla extract' }
      }.each do |ingredient_string, expected|
        context "with ingredient '#{ingredient_string}'" do
          let(:ingredient_string) { ingredient_string }

          it 'correctly parses the ingredient quantity' do
            expect(import.quantity).to eq(expected[:quantity])
          end

          it 'correctly parses the ingredient unit' do
            expect(import.unit).to eq(expected[:unit])
          end

          it 'correctly parses the ingredient name' do
            expect(import.ingredient.name).to eq(expected[:name])
          end
        end
      end
    end

    context 'when an error occurs' do
      before do
        allow(RecipeIngredient).to receive(:find_or_initialize_by).and_raise(StandardError.new('Test error'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error' do
        begin
          import
        rescue StandardError
          StandardError
        end
        expect(Rails.logger).to have_received(:error).with(
          'Failed to import ingredient: 2 cups all-purpose flour, error: Test error'
        )
      end

      it 're-raises the error' do
        expect { import }.to raise_error(StandardError)
      end
    end
  end

  describe 'private methods' do
    describe '#extract_ingredient_name' do
      it 'extracts the correct name' do
        expect(service.send(:extract_name)).to eq('all-purpose flour')
      end
    end

    describe '#extract_quantity' do
      it 'extracts the correct quantity' do
        expect(service.send(:extract_quantity)).to eq('2')
      end

      it 'handles fractional quantities' do
        service = described_class.new(recipe, '1/2 cup sugar')
        expect(service.send(:extract_quantity)).to eq('1/2')
      end

      it 'returns nil when no quantity is present' do
        service = described_class.new(recipe, 'salt to taste')
        expect(service.send(:extract_quantity)).to be_nil
      end
    end

    describe '#extract_unit' do
      it 'extracts the correct unit' do
        expect(service.send(:extract_unit)).to eq('cups')
      end

      it 'returns nil when no valid unit is present' do
        service = described_class.new(recipe, '2 large eggs')
        expect(service.send(:extract_unit)).to be_nil
      end
    end

    describe '#valid_quantity?' do
      it 'returns true for integer quantities' do
        expect(service.send(:valid_quantity?, '2')).to be true
      end

      it 'returns true for fractional quantities' do
        expect(service.send(:valid_quantity?, '1/2')).to be true
      end

      it 'returns true for decimal quantities' do
        expect(service.send(:valid_quantity?, '0.5')).to be true
      end

      it 'returns false for non-numeric quantities' do
        expect(service.send(:valid_quantity?, 'two')).to be false
      end
    end

    describe '#valid_unit?' do
      it 'returns true for singular units' do
        expect(service.send(:valid_unit?, 'cup')).to be true
      end

      it 'returns true for plural units' do
        expect(service.send(:valid_unit?, 'cups')).to be true
      end

      it 'returns false for invalid units' do
        expect(service.send(:valid_unit?, 'invalid')).to be false
      end
    end
  end
end
