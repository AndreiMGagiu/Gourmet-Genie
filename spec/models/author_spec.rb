# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'validations' do
    context 'with a valid name' do
      subject(:user) { build(:user) }

      it { is_expected.to be_valid }
    end

    context 'without a name' do
      subject(:user) { build(:user, name: nil) }

      before { user.validate }

      it { is_expected.not_to be_valid }

      it 'throws a validation error' do
        expect(user.errors[:name]).to include("can't be blank")
      end
    end

    context 'with a duplicate name' do
      subject(:new_user) { build(:user, name: name) }

      let(:name) { 'Bruce Wayne' }

      before do
        create(:user, name: name)
        new_user.validate
      end

      it { is_expected.not_to be_valid }

      it 'throws a uniqueness validation error' do
        expect(new_user.errors[:name]).to include('has already been taken')
      end
    end
  end
end
