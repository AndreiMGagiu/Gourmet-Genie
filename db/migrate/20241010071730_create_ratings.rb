class CreateRatings < ActiveRecord::Migration[7.0]
  def up
    create_table :ratings, id: :uuid do |t|
      t.integer :score, null: false
      t.references :recipe, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :ratings, [:user_id, :recipe_id], unique: true
  end

  def down
    drop_table :ratings
  end
end
