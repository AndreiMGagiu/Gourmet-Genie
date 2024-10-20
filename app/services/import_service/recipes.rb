# frozen_string_literal: true

module ImportService
  # Service class to handle importing of recipe data, including ingredients, dietary requirements, and ratings.
  class Recipes
    # Initializes the Recipes import service with the provided data.
    #
    # @param data [Hash] The recipe data, including title, author, ingredients, category, and ratings.
    def initialize(data)
      @data = data.with_indifferent_access
    end

    # Imports a recipe, its ingredients, dietary requirements, and ratings.
    #
    # The method wraps all database operations in a transaction to ensure data consistency.
    #
    # @raise [ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique] if the recipe or its associations
    # cannot be saved.
    #
    # @return [Recipe] The created or updated Recipe object.
    def import
      ActiveRecord::Base.transaction do
        recipe = create_or_update_recipe
        import_ingredients(recipe)
        assign_dietary_requirements(recipe)
        import_rating(recipe)
        recipe
      end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => error
      log_error(error)
      raise
    end

    private

    attr_reader :data

    # Finds or initializes a recipe based on its title and the author.
    # If the recipe already exists, it updates the attributes; otherwise, a new recipe is created.
    #
    # @return [Recipe] The created or updated Recipe record.
    def create_or_update_recipe
      recipe = Recipe.find_or_initialize_by(title: data[:title], user: find_or_create_user)
      recipe.update!(
        cook_time: data[:cook_time],
        prep_time: data[:prep_time],
        cuisine: data[:cuisine],
        image: sanitize_image_url(data[:image]),
        category: find_or_create_category
      )
      recipe
    end

    # Sanitizes the image URL by extracting the actual URL if it is wrapped in a service URL.
    #
    # @param image_url [String] The potentially wrapped image URL.
    # @return [String, nil] The sanitized image URL or nil if the image_url is blank.
    def sanitize_image_url(image_url)
      return if image_url.blank?

      uri = URI.parse(image_url)
      CGI.parse(uri.query.to_s)['url']&.first || image_url
    end

    # Finds or creates a category for the recipe. If no category is provided, it defaults to the recipe categorizer.
    #
    # @return [Category] The found or newly created Category record.
    def find_or_create_category
      if data[:category].present?
        Category.find_or_create_by!(name: data[:category])
      else
        ImportService::RecipeCategorizer.new(data).find_or_create
      end
    end

    # Finds or creates a user based on the recipe author. Uses 'John Doe' if no author is provided.
    #
    # @return [User] The found or newly created User record.
    def find_or_create_user
      User.find_or_create_by!(name: data[:author].presence || 'John Doe')
    end

    # Imports the ingredients for the recipe.
    #
    # Each ingredient is processed using the ImportService::Ingredients class.
    #
    # @param recipe [Recipe] The Recipe object to associate the ingredients with.
    # @return [void]
    def import_ingredients(recipe)
      data[:ingredients].each do |ingredient_data|
        ImportService::Ingredients.new(recipe, ingredient_data).import
      end
    end

    # Assigns dietary requirements to the recipe based on keywords in the title and ingredients.
    #
    # Uses the ImportService::DietaryRequirements class to detect and assign the appropriate dietary requirements.
    #
    # @param recipe [Recipe] The Recipe object to associate dietary requirements with.
    # @return [void]
    def assign_dietary_requirements(recipe)
      ImportService::DietaryRequirements.new(
        recipe: recipe,
        ingredients: data[:ingredients],
        title: data[:title]
      ).assign
    end

    # Imports the rating for the recipe.
    #
    # Uses the ImportService::Ratings class to process and save the rating data.
    #
    # @param recipe [Recipe] The Recipe object to associate the rating with.
    # @return [void]
    def import_rating(recipe)
      return if data[:ratings].blank?

      ImportService::Ratings.new(
        recipe: recipe,
        rating: data[:ratings],
        user: find_or_create_user
      ).import
    end

    # Logs an error message if the import process fails, providing detailed information about the failure.
    #
    # @param error [StandardError] The error that occurred during the import process.
    # @return [void]
    def log_error(error)
      Rails.logger.error("Failed to import recipe '#{data[:title]}' by user '#{data[:author]}': #{error.message}")
    end
  end
end
