# frozen_string_literal: true

# Represents an author who creates recipes.
#
class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :recipes, dependent: :destroy
end
