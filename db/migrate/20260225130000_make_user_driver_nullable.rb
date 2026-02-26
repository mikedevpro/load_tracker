class MakeUserDriverNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :driver_id, true
  end
end
