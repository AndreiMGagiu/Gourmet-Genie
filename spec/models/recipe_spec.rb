# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe 'validations' do
    context 'with valid attributes' do
      subject(:recipe) { build(:recipe) }

      it { is_expected.to be_valid }
    end

    context 'without a title' do
      subject(:recipe) { build(:recipe, title: nil) }

      before { recipe.validate }

      it { is_expected.not_to be_valid }

      it 'throws a validation error' do
        expect(recipe.errors[:title]).to include("can't be blank")
      end
    end

    context 'with invalid cook_time' do
      subject(:recipe) { build(:recipe, cook_time: -5) }

      before { recipe.validate }

      it { is_expected.not_to be_valid }

      it 'throws a validation error' do
        expect(recipe.errors[:cook_time]).to include('must be greater than or equal to 0')
      end
    end

    context 'with invalid prep_time' do
      subject(:recipe) { build(:recipe, prep_time: -5) }

      before { recipe.validate }

      it { is_expected.not_to be_valid }

      it 'throws a validation error' do
        expect(recipe.errors[:prep_time]).to include('must be greater than or equal to 0')
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:category) }
    it { is_expected.to belong_to(:author) }
  end

  describe 'scopes' do
    describe '.by_cuisine' do
      let!(:italian_recipe) { create(:recipe, cuisine: 'Italian') }
      let!(:mexican_recipe) { create(:recipe, cuisine: 'Mexican') }

      it 'includes recipes of the specified cuisine' do
        expect(described_class.by_cuisine('Italian')).to include(italian_recipe)
      end

      it 'excludes recipes of other cuisines' do
        expect(described_class.by_cuisine('Italian')).not_to include(mexican_recipe)
      end
    end

    describe '.quick_recipes' do
      let!(:quick_recipe) { create(:recipe, cook_time: 20, prep_time: 10) }
      let!(:slow_recipe) { create(:recipe, cook_time: 60, prep_time: 30) }

      it 'includes recipes with cook time <= 30 and prep time <= 15' do
        expect(described_class.quick_recipes).to include(quick_recipe)
      end

      it 'excludes recipes with cook time > 30 or prep time > 15' do
        expect(described_class.quick_recipes).not_to include(slow_recipe)
      end
    end
  end

  describe '.preparable_within' do
    let!(:quick_recipe) { create(:recipe, :quick) }
    let!(:medium_recipe) { create(:recipe, :medium) }
    let!(:slow_recipe) { create(:recipe, :elaborate) }

    context 'when given 30 minutes' do
      it 'includes recipes preparable within 30 minutes' do
        expect(described_class.preparable_within(30)).to include(quick_recipe)
      end

      it 'excludes recipes not preparable within 30 minutes' do
        expect(described_class.preparable_within(30)).not_to include(medium_recipe, slow_recipe)
      end
    end

    context 'when given 45 minutes' do
      it 'includes recipes preparable within 45 minutes' do
        expect(described_class.preparable_within(45)).to include(quick_recipe, medium_recipe)
      end

      it 'excludes recipes not preparable within 45 minutes' do
        expect(described_class.preparable_within(45)).not_to include(slow_recipe)
      end
    end
  end
end
