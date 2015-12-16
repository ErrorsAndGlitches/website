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

ActiveRecord::Schema.define(version: 20151211082702) do

  create_table "albums", force: :cascade do |t|
    t.string   "key",   limit: 255, null: false
    t.string   "title", limit: 255, null: false
    t.string   "cover", limit: 255, null: false
    t.datetime "date",              null: false
  end

  add_index "albums", ["key"], name: "index_albums_on_key", unique: true, using: :btree

  create_table "flight_request_groups", force: :cascade do |t|
    t.integer "trip_id",           limit: 4, null: false
    t.integer "flight_request_id", limit: 4, null: false
  end

  add_index "flight_request_groups", ["flight_request_id"], name: "index_flight_request_groups_on_flight_request_id", using: :btree
  add_index "flight_request_groups", ["trip_id"], name: "index_flight_request_groups_on_trip_id", using: :btree

  create_table "flight_requests", force: :cascade do |t|
    t.string "key",        limit: 255,  null: false
    t.binary "request_gz", limit: 1024, null: false
  end

  add_index "flight_requests", ["key"], name: "index_flight_requests_on_key", using: :btree

  create_table "flight_responses", force: :cascade do |t|
    t.integer  "flight_request_id", limit: 4,        null: false
    t.datetime "date",                               null: false
    t.binary   "full_response_gz",  limit: 16777215, null: false
    t.binary   "response_gz",       limit: 65535,    null: false
  end

  add_index "flight_responses", ["date"], name: "index_flight_responses_on_date", using: :btree
  add_index "flight_responses", ["flight_request_id"], name: "index_flight_responses_on_flight_request_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.integer  "album_id",  limit: 4,   null: false
    t.string   "key",       limit: 255, null: false
    t.string   "raw",       limit: 255, null: false
    t.string   "thumbnail", limit: 255, null: false
    t.datetime "date",                  null: false
  end

  add_index "photos", ["album_id", "key"], name: "index_photos_on_album_id_and_key", unique: true, using: :btree
  add_index "photos", ["album_id"], name: "index_photos_on_album_id", using: :btree

  create_table "trips", force: :cascade do |t|
    t.string "key",       limit: 255, null: false
    t.string "thumbnail", limit: 255, null: false
  end

  add_index "trips", ["key"], name: "index_trips_on_key", using: :btree

  add_foreign_key "flight_request_groups", "flight_requests"
  add_foreign_key "flight_request_groups", "trips"
end
