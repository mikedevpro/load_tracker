class AddRoleAndDriverToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string
    add_reference :users, :driver, null: false, foreign_key: true
  end
end
