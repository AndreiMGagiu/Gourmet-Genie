# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ingredient do
  describe 'validations' do
    context 'with valid attributes' do
      subject(:ingredient) { build(:ingredient) }

      it { is_expected.to be_valid }
    end

    context 'without a name' do
      subject(:ingredient) { build(:ingredient, name: nil) }

      before { ingredient.validate }

      it { is_expected.not_to be_valid }

      it 'throws a validation error' do
        expect(ingredient.errors[:name]).to include("can't be blank")
      end
    end

    context 'with a duplicate name' do
      subject(:new_ingredient) { build(:ingredient, name: existing_ingredient.name) }

      let!(:existing_ingredient) { create(:ingredient) }

      before { new_ingredient.validate }

      it { is_expected.not_to be_valid }

      it 'throws a uniqueness validation error' do
        expect(new_ingredient.errors[:name]).to include('has already been taken')
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:recipe_ingredients) }
    it { is_expected.to have_many(:recipes).through(:recipe_ingredients) }
  end
end
