# frozen_string_literal: true

# lib/tasks/import_recipes.rake

namespace :import do
  desc 'Import recipes from JSON file and process them'
  task recipes: :environment do
    file_path = 'db/data/recipes.json'

    if File.exist?(file_path)
      file_contents = File.read(file_path)
      json_data = JSON.parse(file_contents)
      ImportService::Processor.new(json_data).call
      puts 'Recipes import completed successfully.'
    else
      puts "File not found: #{file_path}"
    end
  rescue JSON::ParserError => error
    puts "Error parsing JSON file: #{error.message}"
  rescue StandardError => error
    puts "An error occurred during the import: #{error.message}"
  end
end
