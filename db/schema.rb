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

ActiveRecord::Schema.define(version: 0) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "BusRouteSequences", primary_key: "route", force: :cascade do |t|
    t.integer "run",             limit: 2,  null: false
    t.integer "sequence",        limit: 2,  null: false
    t.string  "busStopLBSLCode", limit: 10
  end

  create_table "BusStops", primary_key: "lbslCode", force: :cascade do |t|
    t.string  "code",             limit: 10
    t.string  "naptanAtcoCode",   limit: 20
    t.string  "name",             limit: 100
    t.integer "locationEasting"
    t.integer "locationNorthing"
    t.string  "heading",          limit: 4
    t.string  "stopArea",         limit: 15
    t.boolean "virtual"
  end

  create_table "DisruptionComments", force: :cascade do |t|
    t.integer  "disruptionId"
    t.text     "comment"
    t.integer  "operatorId"
    t.datetime "timestamp",    default: "now()", null: false
  end

  create_table "Disruptions", force: :cascade do |t|
    t.string   "fromStopLBSLCode",         limit: 10
    t.string   "toStopLBSLCode",           limit: 10
    t.string   "route",                    limit: 10
    t.integer  "run",                      limit: 2
    t.float    "delayInSeconds"
    t.datetime "firstDetectedAt"
    t.datetime "clearedAt"
    t.boolean  "hide",                                default: false, null: false
    t.integer  "trend",                    limit: 2,  default: 0,     null: false
    t.float    "routeTotalDelayInSeconds"
  end

  create_table "EngineConfigurations", primary_key: "key", force: :cascade do |t|
    t.string  "value",    limit: 500
    t.boolean "editable",             default: false, null: false
  end

  create_table "Operators", force: :cascade do |t|
    t.string  "username", limit: 100
    t.string  "password", limit: 128
    t.boolean "admin"
  end

  create_table "Sections", force: :cascade do |t|
    t.string   "route",                    limit: 10
    t.integer  "run",                      limit: 2
    t.string   "startStopLBSLCode",        limit: 10
    t.string   "endStopLBSLCode",          limit: 10
    t.integer  "sequence",                 limit: 2
    t.datetime "latestLostTimeUpdateTime"
  end

  create_table "SectionsLostTime", primary_key: "serialId", force: :cascade do |t|
    t.integer  "sectionId",            default: "nextval('"SectionsLostTime_sectionId_seq"'::regclass)", null: false
    t.integer  "lostTimeInSeconds"
    t.datetime "timestamp",            default: "now()",                                                 null: false
    t.integer  "numberOfObservations", default: 0,                                                       null: false
  end

  add_foreign_key "BusRouteSequences", "\"BusStops\"", column: "busStopLBSLCode", primary_key: "lbslCode", name: "fk_busStop", on_update: :cascade, on_delete: :restrict
  add_foreign_key "DisruptionComments", "\"Disruptions\"", column: "disruptionId", name: "fk_DisruptionCommentsDisruptionId", on_update: :cascade, on_delete: :restrict
  add_foreign_key "DisruptionComments", "\"Operators\"", column: "operatorId", name: "fk_disruptionCommentsOperatorId", on_update: :cascade, on_delete: :restrict
  add_foreign_key "Disruptions", "\"BusStops\"", column: "fromStopLBSLCode", primary_key: "lbslCode", name: "fk_DisruptionFromBusStop", on_update: :cascade, on_delete: :restrict
  add_foreign_key "Disruptions", "\"BusStops\"", column: "toStopLBSLCode", primary_key: "lbslCode", name: "fk_DisruptionToBusStop", on_update: :cascade, on_delete: :restrict
  add_foreign_key "Sections", "\"BusRouteSequences\"", column: "route", primary_key: "route", name: "fk_SectionBusRouteSequence", on_update: :cascade, on_delete: :restrict
  add_foreign_key "Sections", "\"BusStops\"", column: "endStopLBSLCode", primary_key: "lbslCode", name: "fk_SectionEndStop", on_update: :cascade, on_delete: :restrict
  add_foreign_key "Sections", "\"BusStops\"", column: "startStopLBSLCode", primary_key: "lbslCode", name: "fk_SectionStartStop", on_update: :cascade, on_delete: :restrict
  add_foreign_key "SectionsLostTime", "\"Sections\"", column: "sectionId", name: "fk_SectionIdLostTime", on_update: :cascade, on_delete: :restrict
end
