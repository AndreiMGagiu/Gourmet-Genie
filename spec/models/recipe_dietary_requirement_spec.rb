# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecipeDietaryRequirement do
  describe 'associations' do
    it { is_expected.to belong_to(:recipe) }
    it { is_expected.to belong_to(:dietary_requirement) }
  end
end
