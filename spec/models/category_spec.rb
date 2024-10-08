# frozen_string_literal: true

# spec/models/category_spec.rb
require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    context 'with a valid category name' do
      let(:category) { build(:category, name: 'Unique Category') }

      it 'is valid' do
        expect(category).to be_valid
      end
    end

    context 'without a name' do
      let(:category) { build(:category, name: nil) }

      it 'is not valid' do
        expect(category).not_to be_valid
        expect(category.errors[:name]).to include("can't be blank")
      end
    end

    context 'with a duplicate name' do
      let(:category_name) { 'Duplicate Category' }
      let!(:existing_category) { create(:category, name: category_name) }
      let(:new_category) { build(:category, name: category_name) }

      it 'is not valid' do
        expect(new_category).not_to be_valid
        expect(new_category.errors[:name]).to include('has already been taken')
      end
    end
  end
end
