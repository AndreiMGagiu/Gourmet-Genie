# frozen_string_literal: true

class CreateCategories < ActiveRecord::Migration[7.0]
  def up
    create_table :categories, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :categories, :name, unique: true
  end

  def down
    drop_table :categories
  end
end
