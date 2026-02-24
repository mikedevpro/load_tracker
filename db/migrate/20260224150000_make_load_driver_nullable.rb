class MakeLoadDriverNullable < ActiveRecord::Migration[8.1]
  def change
    change_column_null :loads, :driver_id, true
  end
end
