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

ActiveRecord::Schema.define(:version => 20100113032723) do

  create_table "cities", :force => true do |t|
    t.integer "country_subdivision_id"
    t.integer "country_id"
    t.string  "name"
  end

  add_index "cities", ["country_id"], :name => "index_cities_on_country_id"
  add_index "cities", ["country_subdivision_id"], :name => "index_cities_on_country_subdivision_id"

  create_table "comments", :force => true do |t|
    t.text     "text",             :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.string   "type"
    t.boolean  "anonymous",        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "vote_id"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "countries", :force => true do |t|
    t.string  "name"
    t.string  "code",             :limit => 2
    t.boolean "priority_country",              :default => false
  end

  add_index "countries", ["priority_country"], :name => "index_countries_on_priority_country"

  create_table "country_subdivisions", :force => true do |t|
    t.integer "country_id"
    t.string  "name"
    t.string  "code",       :limit => 2
    t.string  "type"
  end

  add_index "country_subdivisions", ["country_id"], :name => "index_country_subdivisions_on_country_id"
  add_index "country_subdivisions", ["id", "type"], :name => "index_country_subdivisions_on_type_and_id", :unique => true

  create_table "invitations", :force => true do |t|
    t.integer  "voteable_id"
    t.string   "voteable_type"
    t.integer  "created_for"
    t.integer  "created_by"
    t.string   "token",                        :null => false
    t.integer  "status",        :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.integer "locatable_id"
    t.string  "locatable_type"
    t.integer "country_id"
    t.integer "country_subdivision_id"
    t.integer "city_id"
    t.string  "street_address"
    t.string  "postal_code",            :limit => 50
    t.float   "lat"
    t.float   "lng"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "workspace_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "salutation",  :default => ""
    t.string   "name",        :default => ""
    t.string   "title",       :default => ""
    t.text     "description", :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.text     "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sites", :force => true do |t|
    t.string "domain"
    t.string "name"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.string  "taggable_type", :default => ""
    t.integer "taggable_id"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name", :default => ""
    t.string "kind", :default => ""
  end

  add_index "tags", ["kind", "name"], :name => "index_tags_on_name_and_kind"

  create_table "twitter_accounts", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "request_token"
    t.string   "request_token_secret"
    t.text     "request_authorization_url"
    t.string   "access_token"
    t.string   "access_token_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "twitter_accounts", ["owner_id", "owner_type"], :name => "index_twitter_accounts_on_owner_id_and_owner_type", :unique => true

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.integer  "login_count",                       :default => 0, :null => false
    t.integer  "failed_login_count",                :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "role",                :limit => 40
  end

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "fk_voteables"
  add_index "votes", ["voter_id", "voter_type"], :name => "fk_voters"

  create_table "workspaces", :force => true do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.string   "contact_numbers"
    t.text     "description"
    t.text     "urls"
    t.text     "videos"
    t.text     "photos"
    t.integer  "votes_up",        :default => 0
    t.integer  "votes_down",      :default => 0
    t.integer  "votes_rating",    :default => 0
    t.boolean  "delta",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workspaces", ["delta"], :name => "index_workspaces_on_delta"
  add_index "workspaces", ["description"], :name => "index_workspaces_on_description"
  add_index "workspaces", ["name"], :name => "index_workspaces_on_name"

end
