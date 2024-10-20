# frozen_string_literal: true

module ImportService
  # The DietaryRequirements class is responsible for assigning dietary requirements
  # (such as Vegan, Gluten-Free, etc.) to a given recipe based on keywords found in the
  # recipe's title and ingredients.
  #
  # Dietary requirements and their associated keywords are stored in a YAML configuration
  # file (`config/dietary_requirements.yml`), which can be customized using the
  # `config_accessor :requirements_file`.
  class DietaryRequirements
    include ActiveSupport::Configurable

    config_accessor :requirements_file do
      Rails.root.join('config/dietary_requirements.yml')
    end

    # Initializes the DietaryRequirements service.
    #
    # @param [Recipe] recipe The recipe to which dietary requirements will be assigned.
    # @param [Array<String>] ingredients A list of ingredients for the recipe.
    # @param [String] title The title of the recipe.
    def initialize(recipe:, ingredients:, title:)
      @recipe = recipe
      @ingredients = Array(ingredients).map { |i| i.to_s.downcase }
      @title = title.to_s.downcase
      @matched_requirements = Set.new
    end

    # Assigns dietary requirements to the recipe based on matching keywords.
    #
    # @return [void]
    def assign
      return if @ingredients.empty? && @title.empty?

      dietary_requirements.each do |name, keywords|
        @matched_requirements << name if matches_any_keywords?(keywords)
      end
      associate_dietary_requirements
    end

    private

    attr_reader :recipe, :ingredients, :title, :matched_requirements

    # Loads the dietary requirements from the configuration file.
    #
    # The YAML file should contain a mapping of dietary requirement names to their
    # associated keywords. Example:
    #
    # ```yaml
    # vegan:
    #   - tofu
    #   - no animal products
    # gluten_free:
    #   - gluten-free
    #   - rice flour
    # ```
    #
    # @return [Hash] A hash with dietary requirement names as keys and an array of associated keywords as values.
    def dietary_requirements
      @dietary_requirements ||= YAML.load_file(self.class.requirements_file).deep_symbolize_keys
    end

    # Checks if the recipe's title or ingredients match any of the keywords for a dietary requirement.
    #
    # @param [Array<String>] keywords The list of keywords that define the dietary restriction.
    # @return [Boolean] True if any keyword matches the title or ingredients, false otherwise.
    def matches_any_keywords?(keywords)
      keywords.any? { |keyword| title.include?(keyword) || ingredients.any? { |i| i.include?(keyword) } }
    end

    # Associates the dietary requirements with the recipe by creating or finding the corresponding record.
    #
    # @return [void]
    def associate_dietary_requirements
      matched_requirements.each do |requirement_name|
        requirement = DietaryRequirement.find_or_create_by!(name: requirement_name)
        recipe.dietary_requirements << requirement unless recipe.dietary_requirements.include?(requirement)
      end
    end
  end
end
