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

ActiveRecord::Schema[8.1].define(version: 2025_06_06_132412) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "composers", force: :cascade do |t|
    t.text "bio"
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.date "death_date"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "nationality_id"
    t.text "short_bio"
    t.datetime "updated_at", null: false
    t.index ["nationality_id"], name: "index_composers_on_nationality_id"
  end

  create_table "movements", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration"
    t.integer "position", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "work_id", null: false
    t.index ["work_id"], name: "index_movements_on_work_id"
  end

  create_table "nationalities", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_nationalities_on_code", unique: true
    t.index ["name"], name: "index_nationalities_on_name", unique: true
  end

  create_table "quote_details", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.integer "detailable_id", null: false
    t.string "detailable_type", null: false
    t.string "excerpt_text"
    t.string "location"
    t.text "notes"
    t.integer "quote_id", null: false
    t.datetime "updated_at", null: false
    t.index ["detailable_type", "detailable_id"], name: "index_quote_details_on_detailable"
    t.index ["quote_id"], name: "index_quote_details_on_quote_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.string "author", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.text "bio"
    t.string "city"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "firstname"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.string "lastname"
    t.string "phone"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "works", force: :cascade do |t|
    t.integer "composer_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duration"
    t.date "end_date_composed"
    t.integer "form"
    t.string "instrumentation"
    t.string "opus"
    t.boolean "recorded"
    t.date "start_date_composed"
    t.integer "structure"
    t.string "title", null: false
    t.boolean "unsure_end_date"
    t.boolean "unsure_start_date"
    t.datetime "updated_at", null: false
    t.index ["composer_id"], name: "index_works_on_composer_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "composers", "nationalities"
  add_foreign_key "movements", "works"
  add_foreign_key "quote_details", "quotes"
  add_foreign_key "works", "composers"
end
