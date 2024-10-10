class UpdateRecipesTableUserReference < ActiveRecord::Migration[7.0]
  def change
    rename_column :recipes, :author_id, :user_id
  end
end
