# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 6) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: :cascade do |t|
    t.string  "first_name"
    t.string  "last_name"
    t.integer "rating",     default: 0
  end

  create_table "posts", force: :cascade do |t|
    t.text    "title"
    t.text    "body"
    t.text    "tags",      default: [], array: true
    t.integer "author_id"
  end

  create_table "tracked_changes", force: :cascade do |t|
    t.string   "table_name"
    t.integer  "record_id"
    t.string   "column_name"
    t.json     "value"
    t.datetime "changed_at"
  end

  add_index "tracked_changes", ["changed_at"], name: "index_tracked_changes_on_changed_at", using: :btree
  add_index "tracked_changes", ["record_id"], name: "index_tracked_changes_on_record_id", using: :btree
  add_index "tracked_changes", ["table_name", "record_id", "column_name"], name: "record_identifiers", unique: true, using: :btree
  add_index "tracked_changes", ["table_name"], name: "index_tracked_changes_on_table_name", using: :btree

end
