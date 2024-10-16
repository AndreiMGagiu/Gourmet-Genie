class CreateApps < ActiveRecord::Migration[6.1]
  def up
    create_table :apps, id: :uuid do |t|
      t.string :name
      t.string :secret_token
      t.boolean :approved, deafult: false
      t.timestamps null: false
    end
  end

  def down
    drop_table :apps
  end
end
