# frozen_string_literal: true

class CreateRecipes < ActiveRecord::Migration[7.0]
  def up
    create_table :recipes, id: :uuid do |t|
      t.string :title, null: false
      t.integer :cook_time
      t.integer :prep_time
      t.string :cuisine
      t.string :image
      t.references :category, null: false, type: :uuid, foreign_key: true
      t.references :author, null: false, type: :uuid, foreign_key: true

      t.timestamps
    end

    add_index :recipes, [:cook_time, :prep_time]

    add_index :recipes, %i[category_id author_id]
  end

  def down
    drop_table :recipes
  end
end
