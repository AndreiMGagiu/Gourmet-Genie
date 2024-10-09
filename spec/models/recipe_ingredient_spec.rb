# frozen_string_literal: true

# spec/models/recipe_ingredient_spec.rb
require 'rails_helper'

RSpec.describe RecipeIngredient, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:recipe_ingredient)).to be_valid
    end

    it 'is not valid without a quantity' do
      expect(build(:recipe_ingredient, quantity: nil)).not_to be_valid
    end

    it 'is not valid without a unit' do
      expect(build(:recipe_ingredient, unit: nil)).not_to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:recipe) }
    it { is_expected.to belong_to(:ingredient) }
  end
end
