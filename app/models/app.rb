# frozen_string_literal: true

class App < ApplicationRecord
  attr_readonly :secret_token

  before_create :generate_token

  validates :name, presence: true, uniqueness: true

  scope :approved, -> { where(approved: true) }

  private

  def generate_token
    self.secret_token = loop do
      token = SecureRandom.urlsafe_base64(nil, false)
      break token unless App.unscoped.exists?(secret_token: token)
    end
  end
end
