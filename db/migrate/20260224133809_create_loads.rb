class CreateLoads < ActiveRecord::Migration[8.1]
  def change
    create_table :loads do |t|
      t.string :reference_number
      t.string :status
      t.date :pickup_date
      t.date :delivery_date
      t.string :origin_city
      t.string :dest_city
      t.decimal :rate
      t.references :customer, null: false, foreign_key: true
      t.references :driver, null: false, foreign_key: true

      t.timestamps
    end
  end
end
