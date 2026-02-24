# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_24_150000) do
  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "drivers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  create_table "loads", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id", null: false
    t.date "delivery_date"
    t.string "dest_city"
    t.integer "driver_id"
    t.string "origin_city"
    t.date "pickup_date"
    t.decimal "rate"
    t.string "reference_number"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_loads_on_customer_id"
    t.index ["driver_id"], name: "index_loads_on_driver_id"
  end

  create_table "status_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "load_id", null: false
    t.string "note"
    t.datetime "occurred_at"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["load_id"], name: "index_status_events_on_load_id"
  end

  add_foreign_key "loads", "customers"
  add_foreign_key "loads", "drivers"
  add_foreign_key "status_events", "loads"
end
