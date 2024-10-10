# frozen_string_literal: true

# Represents the association between a Recipe and a DietaryRequirement.
# This is a join model that allows for a many-to-many relationship between recipes and dietary requirements.
#
# @!attribute recipe
#   @return [Recipe] The recipe associated with this dietary requirement
# @!attribute dietary_requirement
#   @return [DietaryRequirement] The dietary requirement associated with this recipe
class RecipeDietaryRequirement < ApplicationRecord
  belongs_to :recipe
  belongs_to :dietary_requirement
end
