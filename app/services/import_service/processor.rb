# frozen_string_literal: true

module ImportService
  # Processes a batch of recipe data for import
  class Processor
    # Initializes the Processor with an array of recipe data
    #
    # @param data [Array<Hash>] The array of recipe data to be imported
    def initialize(data)
      @data = data
    end

    attr_reader :data

    # Executes the import of the batch of recipe data within a database transaction
    #
    # @return [void]
    # @raise [ActiveRecord::RecordInvalid] If any of the recipe imports are invalid
    # @raise [ActiveRecord::RecordNotUnique] If any unique constraint is violated during the import
    def call
      ActiveRecord::Base.transaction do
        data.each { |recipe| ImportService::Recipes.new(recipe).import }
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => error
      Rails.logger.error("Failed to import batch of recipes: #{error.message}")
      nil
    end
  end
end
