class CreateIngredients < ActiveRecord::Migration[7.0]
  def up
    create_table :ingredients, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :ingredients, :name, unique: true
  end

  def down
    drop_table :ingredients
  end
end
