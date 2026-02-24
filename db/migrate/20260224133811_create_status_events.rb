class CreateStatusEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :status_events do |t|
      t.string :status
      t.datetime :occurred_at
      t.string :note
      t.references :load, null: false, foreign_key: true

      t.timestamps
    end
  end
end
