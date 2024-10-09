# frozen_string_literal: true

# Represents an author who creates recipes.
#
class Author < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
