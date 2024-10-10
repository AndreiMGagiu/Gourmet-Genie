class RenameAuthorTableToUsers < ActiveRecord::Migration[7.0]
  def change
    rename_table :authors, :users
  end
end
