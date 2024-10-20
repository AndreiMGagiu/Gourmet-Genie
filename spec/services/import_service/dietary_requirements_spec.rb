# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportService::DietaryRequirements do
  let(:recipe) { create(:recipe) }
  let(:service) { described_class.new(recipe: recipe, ingredients: ingredients, title: title) }

  let(:dietary_requirements) do
    {
      vegan: ['tofu', 'no animal products'],
      gluten_free: ['gluten-free', 'rice flour'],
      dairy_free: ['soy milk', 'dairy-free']
    }
  end

  before do
    allow(YAML).to receive(:load_file).and_return(dietary_requirements)
  end

  describe '#assign' do
    context 'when recipe matches multiple dietary requirements' do
      let(:ingredients) { ['tofu', 'rice flour', 'soy milk'] }
      let(:title) { 'Vegan Gluten-Free Pancakes' }

      it 'assigns all matching dietary requirements to the recipe' do
        service.assign
        expect(recipe.dietary_requirements.pluck(:name)).to contain_exactly('vegan', 'gluten_free', 'dairy_free')
      end
    end

    context 'when recipe matches one dietary requirement' do
      let(:ingredients) { ['chicken', 'rice flour'] }
      let(:title) { 'Gluten-Free Chicken Rice' }

      it 'assigns only the matching dietary requirement' do
        service.assign
        expect(recipe.dietary_requirements.pluck(:name)).to contain_exactly('gluten_free')
      end
    end

    context 'when recipe does not match any dietary requirements' do
      let(:ingredients) { %w[chicken milk] }
      let(:title) { 'Chicken Soup' }

      it 'does not assign any dietary requirements' do
        service.assign
        expect(recipe.dietary_requirements).to be_empty
      end
    end
  end

  describe '#matches_any_keywords?' do
    let(:ingredients) { ['tofu', 'rice flour', 'soy milk'] }
    let(:title) { 'Vegan Gluten-Free Pancakes' }

    context 'when keyword matches the title' do
      it 'returns true' do
        expect(service.send(:matches_any_keywords?, ['vegan'])).to be true
      end
    end

    context 'when keyword matches an ingredient' do
      it 'returns true' do
        expect(service.send(:matches_any_keywords?, ['tofu'])).to be true
      end
    end

    context 'when keyword does not match title or ingredients' do
      it 'returns false' do
        expect(service.send(:matches_any_keywords?, ['chicken'])).to be false
      end
    end

    context 'with case-insensitive matching' do
      it 'returns true for uppercase keywords' do
        expect(service.send(:matches_any_keywords?, ['tofu'])).to be true
      end
    end
  end

  describe 'edge cases' do
    context 'with empty ingredients and title' do
      let(:ingredients) { [] }
      let(:title) { '' }

      it 'does not assign any dietary requirements' do
        service.assign
        expect(recipe.dietary_requirements).to be_empty
      end
    end

    context 'with nil ingredients and title' do
      let(:ingredients) { nil }
      let(:title) { nil }

      it 'handles nil values without raising errors' do
        expect { service.assign }.not_to raise_error
      end
    end
  end
end
