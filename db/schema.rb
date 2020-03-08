# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_07_164908) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "frames", force: :cascade do |t|
    t.integer "score"
    t.integer "game_id"
    t.integer "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_frames_on_created_at"
    t.index ["game_id"], name: "index_frames_on_game_id"
    t.index ["state"], name: "index_frames_on_state"
  end

  create_table "games", force: :cascade do |t|
    t.integer "state"
    t.integer "score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "throws", force: :cascade do |t|
    t.integer "knocked_pins"
    t.integer "frame_id"
    t.integer "knock_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_throws_on_created_at"
    t.index ["frame_id"], name: "index_throws_on_frame_id"
    t.index ["knock_type"], name: "index_throws_on_knock_type"
  end

end
