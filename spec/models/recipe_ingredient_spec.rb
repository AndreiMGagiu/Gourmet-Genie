# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecipeIngredient do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:recipe_ingredient)).to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:recipe) }
    it { is_expected.to belong_to(:ingredient) }
  end
end
