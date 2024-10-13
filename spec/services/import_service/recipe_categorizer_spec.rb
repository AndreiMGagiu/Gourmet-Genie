# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportService::RecipeCategorizer do
  describe '#determine_category' do
    subject(:category) { described_class.new(recipe_data).determine_category }

    context 'when the recipe title and ingredients suggest a specific category' do
      let(:recipe_data) do
        {
          'title' => 'Classic Banana Bread',
          'ingredients' => %w[flour banana sugar],
          'category' => ''
        }
      end

      it { is_expected.to eq('Baking') }
    end

    context 'when the recipe is categorized by cooking method' do
      let(:recipe_data) do
        {
          'title' => 'Slow Cooker Sweet and Sour Chicken Thighs',
          'ingredients' => ['chicken thighs', 'pineapple', 'soy sauce'],
          'category' => ''
        }
      end

      it { is_expected.to eq('Slow Cooker') }
    end

    context 'when there is no clear category' do
      let(:recipe_data) do
        {
          'title' => 'Mystery Dish',
          'ingredients' => ['secret ingredient', 'love', 'magic'],
          'category' => ''
        }
      end

      it { is_expected.to eq('Uncategorized') }
    end
  end

  describe 'private methods' do
    let(:recipe_data) do
      {
        'title' => 'chocolate cake',
        'ingredients' => %w[flour sugar chocolate eggs]
      }
    end
    let(:categorizer) { described_class.new(recipe_data) }

    describe '#categorize_by_keywords' do
      subject(:category) { categorizer.send(:categorize_by_keywords) }

      it { is_expected.to eq('Dessert') }

      context 'when no category has a score above zero' do
        let(:recipe_data) do
          {
            'title' => 'mystery dish',
            'ingredients' => ['unknown ingredient']
          }
        end

        it { is_expected.to be_nil }
      end
    end

    describe '#calculate_category_scores' do
      subject(:scores) { categorizer.send(:calculate_category_scores) }

      let(:recipe_data) do
        {
          'title' => 'chocolate chip cookies',
          'ingredients' => ['flour', 'sugar', 'chocolate chips']
        }
      end

      it 'calculates scores for each category based on keyword matches' do
        expect(scores['Baking']).to be > 0
        expect(scores['Dessert']).to be > 0
        expect(scores['Soup']).to eq(0)
      end
    end

    describe '#calculate_keyword_score' do
      subject(:score) { categorizer.send(:calculate_keyword_score, keyword) }

      context 'when the keyword matches exactly in the title' do
        let(:recipe_data) { { 'title' => 'banana bread', 'ingredients' => [] } }
        let(:keyword) { 'bread' }

        it { is_expected.to eq(3) }
      end

      context 'when the keyword partially matches in the title' do
        let(:recipe_data) { { 'title' => 'breadsticks', 'ingredients' => [] } }
        let(:keyword) { 'bread' }

        it { is_expected.to eq(2) }
      end

      context 'when the keyword exactly matches in the ingredients' do
        let(:recipe_data) { { 'title' => 'mystery dish', 'ingredients' => ['wheat flour'] } }
        let(:keyword) { 'flour' }

        it { is_expected.to eq(1) }
      end

      context 'when the keyword is not found' do
        let(:recipe_data) { { 'title' => 'mystery dish', 'ingredients' => %w[flour sugar] } }
        let(:keyword) { 'pizza' }

        it { is_expected.to eq(0) }
      end
    end

    describe '#categorize_by_cooking_method' do
      subject(:category) { categorizer.send(:categorize_by_cooking_method) }

      context 'when the cooking method is found in the title' do
        let(:recipe_data) { { 'title' => 'slow cooker chicken', 'ingredients' => [] } }

        it { is_expected.to eq('Slow Cooker') }
      end

      context 'when the cooking method is found in the ingredients' do
        let(:recipe_data) { { 'title' => 'chicken dish', 'ingredients' => ['slow cooker sauce'] } }

        it { is_expected.to eq('Slow Cooker') }
      end

      context 'when no cooking method is found' do
        let(:recipe_data) { { 'title' => 'mystery dish', 'ingredients' => ['secret sauce'] } }

        it { is_expected.to be_nil }
      end
    end
  end
end
