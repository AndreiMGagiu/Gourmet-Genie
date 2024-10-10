# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rating, type: :model do
  let(:user) { create(:user) }
  let(:recipe) { create(:recipe) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:score) }
    it { is_expected.to validate_inclusion_of(:score).in_range(1..5) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:recipe) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'uniqueness' do
    context 'when multiple users rate the same recipe' do
      let(:other_user) { create(:user) }

      it 'allows multiple ratings for the same recipe by different users' do
        create(:rating, recipe:, user: other_user)
        expect(build(:rating, recipe:)).to be_valid
      end
    end

    context 'when the same user rates different recipes' do
      let(:another_recipe) { create(:recipe) }

      it 'allows multiple ratings by the same user for different recipes' do
        create(:rating, user:, recipe: another_recipe)
        expect(build(:rating, user:)).to be_valid
      end
    end

    context 'when the same user tries to rate the same recipe twice' do
      subject { create(:rating, user:, recipe:) }

      it 'does not allow duplicate ratings' do
        duplicate_rating = build(:rating, user: subject.user, recipe: subject.recipe)
        expect(duplicate_rating).not_to be_valid
        expect(duplicate_rating.errors[:user_id]).to include('can only rate a recipe once')
      end
    end
  end
end
