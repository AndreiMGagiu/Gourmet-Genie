# frozen_string_literal: true

class CreateAuthors < ActiveRecord::Migration[7.0]
  def up
    create_table :authors do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :authors, :name, unique: true
  end

  def down
    drop_table :authors
  end
end
