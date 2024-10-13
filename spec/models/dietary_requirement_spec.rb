# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DietaryRequirement do
  describe 'validations' do
    subject { create(:dietary_requirement) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:recipe_dietary_requirements) }
    it { is_expected.to have_many(:recipes).through(:recipe_dietary_requirements) }
  end
end
