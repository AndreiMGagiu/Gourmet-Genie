# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImportService::Ratings do
  let(:recipe) { create(:recipe) }
  let(:user) { create(:user) }
  let(:rating) { 4.5 }
  let(:service) { described_class.new(recipe:, rating:, user:) }

  describe '#import' do
    subject(:import) { service.import }

    context 'when the rating does not exist' do
      it 'creates a new rating' do
        expect { import }.to change(Rating, :count).by(1)
      end

      it 'associates the rating with the correct recipe' do
        expect(import.recipe).to eq(recipe)
      end

      it 'associates the rating with the correct user' do
        expect(import.user).to eq(user)
      end

      it 'sets the correct normalized score' do
        expect(import.score).to eq(5)
      end
    end

    context 'when the rating already exists for the user and recipe' do
      before do
        create(:rating, user:, recipe:, score: 3)
      end

      it 'raises an ActiveRecord::RecordInvalid error' do
        expect { import }.to raise_error(ActiveRecord::RecordInvalid, /User can only rate a recipe once/)
      end
    end
  end

  describe '#normalized_rating' do
    subject(:normalized_rating) { service.send(:normalized_rating) }

    context 'when rating is below 1' do
      let(:rating) { 0.5 }

      it { is_expected.to eq(1) }
    end

    context 'when rating is above 5' do
      let(:rating) { 5.5 }

      it { is_expected.to eq(5) }
    end

    context 'when rating is between 1 and 5' do
      let(:rating) { 3.4 }

      it { is_expected.to eq(3) }
    end

    context 'when rating is exactly 1' do
      let(:rating) { 1.0 }

      it { is_expected.to eq(1) }
    end

    context 'when rating is exactly 5' do
      let(:rating) { 5.0 }

      it { is_expected.to eq(5) }
    end
  end
end
