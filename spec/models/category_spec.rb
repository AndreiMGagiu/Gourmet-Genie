# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    context 'with a valid category name' do
      subject(:category) { build(:category, name: 'Unique Category') }

      it { is_expected.to be_valid }
    end

    context 'without a name' do
      subject(:category) { build(:category, name: nil) }

      before { category.validate }

      it { is_expected.not_to be_valid }

      it 'throws a validation error' do
        expect(category.errors[:name]).to include("can't be blank")
      end
    end

    context 'with a duplicate name' do
      subject(:new_category) { build(:category, name: category_name) }

      let(:category_name) { 'Duplicate Category' }

      before do
        create(:category, name: category_name)
        new_category.validate
      end

      it { is_expected.not_to be_valid }

      it 'throws a uniqueness validation error' do
        expect(new_category.errors[:name]).to include('has already been taken')
      end
    end
  end
end
