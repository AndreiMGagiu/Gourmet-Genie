# frozen_string_literal: true

# Represents a user's rating for a recipe
#
# @attr [Integer] score The rating score given by the user (typically 1-5)
# @attr [Recipe] recipe The recipe being rated
# @attr [User] user The user who provided the rating
class Rating < ApplicationRecord
  belongs_to :recipe
  belongs_to :user

  validates :score, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :recipe_id, message: 'can only rate a recipe once' }

end
