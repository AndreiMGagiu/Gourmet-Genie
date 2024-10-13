# frozen_string_literal: true

module ImportService
  # Handles the import of rating data for recipes
  class Ratings
    # Initializes a new instance of the Ratings import service
    #
    # @param recipe [Recipe] The recipe being rated
    # @param score [Float] The raw score for the rating
    # @param user [User] The user who provided the rating
    def initialize(recipe, score, user)
      @recipe = recipe
      @score = score.to_f
      @user = user
    end

    # Imports the rating data by creating a new Rating record
    #
    # @return [Rating] The newly created Rating object
    # @raise [ActiveRecord::RecordInvalid] If the rating is invalid
    def import
      Rating.create!(attributes)
    end

    private

    attr_reader :recipe, :score, :user

    # Prepares the attributes for creating a new Rating
    #
    # @return [Hash] The attributes to be used when creating the Rating record
    def attributes
      {
        score: normalized_score,
        recipe: recipe,
        user: user
      }
    end

    # Normalizes the score to a value between 1 and 5
    #
    # @return [Integer] The normalized score, clamped between 1 and 5
    def normalized_score
      score.round.clamp(1, 5)
    end
  end
end
