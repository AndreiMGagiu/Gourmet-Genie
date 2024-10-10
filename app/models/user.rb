# frozen_string_literal: true

# Represents a user who creates recipes.
#
class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :ratings
  has_many :recipes, dependent: :destroy
end
