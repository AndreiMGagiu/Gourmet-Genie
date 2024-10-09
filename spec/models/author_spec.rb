# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author, type: :model do
  describe 'validations' do
    context 'with a valid name' do
      subject(:author) { build(:author) }

      it { is_expected.to be_valid }
    end

    context 'without a name' do
      subject(:author) { build(:author, name: nil) }

      before { author.validate }

      it { is_expected.not_to be_valid }

      it 'throws a validation error' do
        expect(author.errors[:name]).to include("can't be blank")
      end
    end

    context 'with a duplicate name' do
      subject(:new_author) { build(:author, name: name) }

      let(:name) { 'Bruce Wayne' }

      before do
        create(:author, name: name)
        new_author.validate
      end

      it { is_expected.not_to be_valid }

      it 'throws a uniqueness validation error' do
        expect(new_author.errors[:name]).to include('has already been taken')
      end
    end
  end
end
