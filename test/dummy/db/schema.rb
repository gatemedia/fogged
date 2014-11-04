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

ActiveRecord::Schema.define(version: 20141104135257) do

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "fogged_resources", force: true do |t|
    t.string   "name",              null: false
    t.string   "token",             null: false
    t.integer  "width"
    t.integer  "height"
    t.string   "extension",         null: false
    t.boolean  "uploading"
    t.string   "content_type",      null: false
    t.integer  "encoding_progress"
    t.string   "encoding_job_id"
    t.integer  "duration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fogged_resources", ["token"], name: "index_fogged_resources_on_token"

  create_table "images", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
