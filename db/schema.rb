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

ActiveRecord::Schema.define(version: 20180531193247) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "buildings", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "description"
    t.integer  "campus_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "buildings", ["campus_id"], name: "index_buildings_on_campus_id", using: :btree

  create_table "campuses", force: :cascade do |t|
    t.string   "name",        limit: 32, null: false
    t.string   "description", limit: 64
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "campuses", ["name"], name: "index_campuses_on_name", unique: true, using: :btree

  create_table "floors", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "building_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "floors", ["building_id"], name: "index_floors_on_building_id", using: :btree

  create_table "points", force: :cascade do |t|
    t.float    "ox"
    t.float    "oy"
    t.integer  "priority"
    t.integer  "polygon_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "points", ["polygon_id"], name: "index_points_on_polygon_id", using: :btree

  create_table "polygons", force: :cascade do |t|
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "polygons", ["imageable_type", "imageable_id"], name: "index_polygons_on_imageable_type_and_imageable_id", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "floor_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "capacity"
    t.integer  "computers"
    t.integer  "roomtype_id"
  end

  add_index "rooms", ["floor_id"], name: "index_rooms_on_floor_id", using: :btree
  add_index "rooms", ["roomtype_id"], name: "index_rooms_on_roomtype_id", using: :btree

  create_table "roomtypes", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "last_name"
    t.string   "first_name"
    t.string   "patronymic"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "buildings", "campuses"
  add_foreign_key "floors", "buildings"
  add_foreign_key "points", "polygons"
  add_foreign_key "rooms", "floors"
  add_foreign_key "rooms", "roomtypes"
end
