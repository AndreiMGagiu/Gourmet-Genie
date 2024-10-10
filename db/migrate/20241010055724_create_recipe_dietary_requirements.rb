# frozen_string_literal: true

# db/migrate/YYYYMMDDHHMMSS_create_recipe_dietary_requirements.rb
class CreateRecipeDietaryRequirements < ActiveRecord::Migration[7.0]
  def change
    create_table :recipe_dietary_requirements, id: :uuid do |t|
      t.references :recipe, null: false, foreign_key: true, type: :uuid
      t.references :dietary_requirement, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
    add_index :recipe_dietary_requirements, %i[recipe_id dietary_requirement_id], unique: true,
      name: 'unique_recipe_dietary_req'
  end
end
