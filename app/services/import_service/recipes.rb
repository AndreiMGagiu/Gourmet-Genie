# frozen_string_literal: true

module ImportService
  # Handles the import of recipe data into the database. It creates or updates a recipe
  # and its associated data, including ingredients and ratings, while handling transactions
  # and logging any errors that occur during the process.
  class Recipes
    # Initializes the recipe import service with the provided recipe data.
    #
    # @param data [Hash] The recipe data to be imported, including title, ingredients, author, etc.
    def initialize(data)
      @data = data
    end

    # Imports the recipe and its associated data (ingredients, ratings) into the database.
    # If the recipe already exists (based on the title and author), it will be updated with new data.
    # The method handles everything inside a database transaction for data consistency.
    #
    # @return [Recipe] The created or updated Recipe record.
    # @raise [StandardError] Raises an error if the import process fails at any stage.
    def import
      ActiveRecord::Base.transaction do
        recipe = create_or_update_recipe
        import_ingredients(recipe)
        import_rating(recipe)
        recipe
      end
    rescue ActiveRecord::RecordNotUnique => error
      log_error(error)
      raise
    end

    private

    attr_reader :data

    # Finds or initializes a recipe based on its title and the author. If the recipe already exists,
    # it updates the attributes, otherwise, a new recipe is created.
    #
    # @return [Recipe] The created or updated Recipe record.
    def create_or_update_recipe
      recipe = find_or_initialize_recipe
      update_recipe_attributes(recipe)
      recipe.save!
      recipe
    end

    # Finds an existing recipe by title and author or initializes a new one if it does not exist.
    #
    # @return [Recipe] The found or newly initialized Recipe record.
    def find_or_initialize_recipe
      Recipe.find_or_initialize_by(title: data['title'], user: find_or_create_user)
    end

    # Updates the recipe's attributes, such as cooking time, preparation time, cuisine, image, and category.
    #
    # @param recipe [Recipe] The Recipe object to be updated.
    def update_recipe_attributes(recipe)
      recipe.assign_attributes(
        cook_time: data['cook_time'],
        prep_time: data['prep_time'],
        cuisine: data['cuisine'],
        image: data['image'],
        category: find_or_create_category
      )
    end

    # Finds or creates a category for the recipe based on the category name in the data.
    # If no category is provided, the RecipeCategorizer service is used to determine the category.
    #
    # @return [Category] The found or newly created Category record.
    def find_or_create_category
      return Category.find_or_create_by!(name: data['category']) if data['category'].present?

      ImportService::RecipeCategorizer.find_or_create(data)
    end

    # Finds or creates a user based on the recipe author. If no author is provided, a default 'John Doe' is used.
    #
    # @return [User] The found or newly created User record.
    def find_or_create_user
      User.find_or_create_by!(name: data['author'].presence || 'John Doe')
    end

    # Imports the ingredients for the recipe by calling the Ingredients service for each ingredient in the data.
    #
    # @param recipe [Recipe] The Recipe object to associate ingredients with.
    def import_ingredients(recipe)
      data['ingredients'].each do |ingredient_data|
        ImportService::Ingredients.new(recipe, ingredient_data).import
      end
    end

    # Imports the rating for the recipe by calling the Ratings service.
    #
    # @param recipe [Recipe] The Recipe object to associate the rating with.
    def import_rating(recipe)
      ImportService::Ratings.new(recipe, data['ratings'], find_or_create_user).import
    end

    # Logs an error message if the import process fails, providing detailed information about the failure.
    #
    # @param error [StandardError] The error that occurred during the import process.
    def log_error(error)
      Rails.logger.error("Failed to import recipe: #{data['title']}, error: #{error.message}")
    end
  end
end
