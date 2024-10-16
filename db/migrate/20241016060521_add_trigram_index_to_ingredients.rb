class AddTrigramIndexToIngredients < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')

    if index_exists?(:ingredients, :name)
      remove_index :ingredients, :name
    end

    add_index :ingredients, :name, using: :gin, opclass: :gin_trgm_ops
  end
end
