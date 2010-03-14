# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091112172527) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "links", :force => true do |t|
    t.integer  "source_url_id"
    t.integer  "post_id"
    t.string   "url"
    t.string   "status",              :default => "uncrawwwled"
    t.string   "original_image_path", :default => "/images/missing.png"
    t.text     "description"
    t.text     "images"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "posts", :force => true do |t|
    t.string   "name"
    t.string   "thumbnail_dimension"
    t.integer  "total_links"
    t.integer  "columns"
    t.string   "link_order"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_path_prefix",   :default => ""
  end

  create_table "source_urls", :force => true do |t|
    t.string   "url"
    t.text     "html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
