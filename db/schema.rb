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

ActiveRecord::Schema.define(version: 20150925215129) do

  create_table "airports", force: :cascade do |t|
    t.string "acronym",   limit: 255, null: false
    t.string "full_name", limit: 255, null: false
  end

  add_index "airports", ["acronym"], name: "index_airports_on_acronym", unique: true, using: :btree

  create_table "albums", force: :cascade do |t|
    t.string   "key",   limit: 255, null: false
    t.string   "title", limit: 255, null: false
    t.string   "cover", limit: 255, null: false
    t.datetime "date",              null: false
  end

  add_index "albums", ["key"], name: "index_albums_on_key", unique: true, using: :btree

  create_table "flight_data", force: :cascade do |t|
    t.integer  "flight_query_id", limit: 4,                           null: false
    t.datetime "date",                                                null: false
    t.integer  "rank",            limit: 4,                           null: false
    t.decimal  "cost",                        precision: 7, scale: 2, null: false
    t.string   "carrier",         limit: 255,                         null: false
    t.string   "legs",            limit: 255,                         null: false
  end

  add_index "flight_data", ["date"], name: "index_flight_data_on_date", using: :btree
  add_index "flight_data", ["flight_query_id", "date", "rank"], name: "index_flight_data_on_flight_query_id_and_date_and_rank", unique: true, using: :btree
  add_index "flight_data", ["flight_query_id"], name: "index_flight_data_on_flight_query_id", using: :btree
  add_index "flight_data", ["rank"], name: "index_flight_data_on_rank", using: :btree

  create_table "flight_endpoints", force: :cascade do |t|
    t.integer "flight_query_id", limit: 4, null: false
    t.integer "airport_id",      limit: 4, null: false
    t.integer "endpoint_type",   limit: 1, null: false
  end

  add_index "flight_endpoints", ["airport_id"], name: "index_flight_endpoints_on_airport_id", using: :btree
  add_index "flight_endpoints", ["flight_query_id"], name: "index_flight_endpoints_on_flight_query_id", using: :btree

  create_table "flight_queries", force: :cascade do |t|
    t.string  "source_city",       limit: 255, null: false
    t.string  "destination_city",  limit: 255, null: false
    t.date    "departure_date",                null: false
    t.date    "return_date",                   null: false
    t.string  "thumbnail",         limit: 255, null: false
    t.string  "key",               limit: 255, null: false
    t.string  "short_description", limit: 255, null: false
    t.integer "interval",          limit: 4,   null: false
  end

  add_index "flight_queries", ["key"], name: "index_flight_queries_on_key", unique: true, using: :btree

  create_table "photos", force: :cascade do |t|
    t.integer  "album_id",  limit: 4,   null: false
    t.string   "key",       limit: 255, null: false
    t.string   "raw",       limit: 255, null: false
    t.string   "thumbnail", limit: 255, null: false
    t.datetime "date",                  null: false
  end

  add_index "photos", ["album_id", "key"], name: "index_photos_on_album_id_and_key", unique: true, using: :btree
  add_index "photos", ["album_id"], name: "index_photos_on_album_id", using: :btree

end
