# frozen_string_literal: true

# db/migrate/YYYYMMDDHHMMSS_create_dietary_requirements.rb
class CreateDietaryRequirements < ActiveRecord::Migration[7.0]
  def up
    create_table :dietary_requirements, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :dietary_requirements, :name, unique: true
  end

  def down
    drop_table :dietary_requirements
  end
end
