class CreateRecipeIngredients < ActiveRecord::Migration[7.0]
  def up
    create_table :recipe_ingredients, id: :uuid do |t|
      t.references :recipe, null: false, foreign_key: true, type: :uuid
      t.references :ingredient, null: false, foreign_key: true, type: :uuid
      t.string :quantity
      t.string :unit

      t.timestamps
    end

    add_index :recipe_ingredients, [:recipe_id, :ingredient_id], unique: true
  end

  def down
    drop_table :recipe_ingredients
  end
end
