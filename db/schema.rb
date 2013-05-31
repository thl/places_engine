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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130213214759) do
  
  create_table "altitudes", :force => true do |t|
    t.integer  "feature_id", :null => false
    t.integer  "maximum"
    t.integer  "minimum"
    t.integer  "average"
    t.integer  "unit_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "estimate"
  end

  create_table "authors_descriptions", :id => false, :force => true do |t|
    t.integer "description_id", :null => false
    t.integer "author_id",      :null => false
  end

  create_table "authors_notes", :id => false, :force => true do |t|
    t.integer "note_id",   :null => false
    t.integer "author_id", :null => false
  end

  create_table "blurbs", :force => true do |t|
    t.string   "code"
    t.string   "title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cached_category_counts", :force => true do |t|
    t.integer  "category_id",       :null => false
    t.integer  "count",             :null => false
    t.datetime "cache_updated_at",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count_with_shapes", :null => false
  end

  add_index "cached_category_counts", ["category_id"], :name => "index_cached_category_counts_on_category_id", :unique => true

  create_table "cached_feature_names", :force => true do |t|
    t.integer  "feature_id",      :null => false
    t.integer  "view_id",         :null => false
    t.integer  "feature_name_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cached_feature_names", ["feature_id", "view_id"], :name => "index_cached_feature_names_on_feature_id_and_view_id", :unique => true

  create_table "cached_feature_relation_categories", :force => true do |t|
    t.integer  "feature_id"
    t.integer  "related_feature_id"
    t.integer  "category_id"
    t.integer  "perspective_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feature_relation_type_id"
    t.boolean  "feature_is_parent"
  end

  create_table "category_features", :force => true do |t|
    t.integer  "feature_id",                        :null => false
    t.integer  "category_id",                       :null => false
    t.integer  "perspective_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",       :default => 0,     :null => false
    t.string   "type"
    t.string   "string_value"
    t.integer  "numeric_value"
    t.boolean  "show_parent",    :default => false, :null => false
    t.boolean  "show_root",      :default => true,  :null => false
    t.string   "label"
    t.boolean  "prefix_label",   :default => true,  :null => false
  end

  add_index "category_features", ["category_id"], :name => "feature_object_types_object_type_id_idx"
  add_index "category_features", ["feature_id"], :name => "feature_object_types_feature_id_idx"
  add_index "category_features", ["perspective_id"], :name => "feature_object_types_perspective_id_idx"

  create_table "citations", :force => true do |t|
    t.integer  "info_source_id"
    t.string   "citable_type"
    t.integer  "citable_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "citations", ["citable_id", "citable_type"], :name => "citations_1_idx"
  add_index "citations", ["info_source_id"], :name => "citations_info_source_id_idx"

  create_table "complex_dates", :force => true do |t|
    t.integer  "year"
    t.integer  "year_certainty_id"
    t.integer  "season_id"
    t.integer  "season_certainty_id"
    t.integer  "month"
    t.integer  "month_certainty_id"
    t.integer  "day"
    t.integer  "day_certainty_id"
    t.integer  "day_of_week_id"
    t.integer  "day_of_week_certainty_id"
    t.integer  "time_of_day_id"
    t.integer  "time_of_day_certainty_id"
    t.integer  "hour"
    t.integer  "hour_certainty_id"
    t.integer  "minute"
    t.integer  "minute_certainty_id"
    t.integer  "animal_id"
    t.integer  "animal_certainty_id"
    t.integer  "calendrical_id"
    t.integer  "calendrical_certainty_id"
    t.integer  "element_certainty_id"
    t.integer  "element_id"
    t.integer  "gender_id"
    t.integer  "gender_certainty_id"
    t.integer  "intercalary_month_id"
    t.integer  "intercalary_day_id"
    t.integer  "rabjung_id"
    t.integer  "rabjung_certainty_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year_end"
    t.integer  "season_end_id"
    t.integer  "month_end"
    t.integer  "day_end"
    t.integer  "day_of_week_end_id"
    t.integer  "time_of_day_end_id"
    t.integer  "hour_end"
    t.integer  "minute_end"
    t.integer  "rabjung_end_id"
    t.integer  "intercalary_month_end_id"
    t.integer  "intercalary_day_end_id"
  end

  create_table "contestations", :force => true do |t|
    t.integer  "feature_id",                         :null => false
    t.boolean  "contested",        :default => true, :null => false
    t.integer  "administrator_id"
    t.integer  "claimant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cumulative_category_feature_associations", :force => true do |t|
    t.integer  "feature_id",  :null => false
    t.integer  "category_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cumulative_category_feature_associations", ["category_id", "feature_id"], :name => "by_category_feature", :unique => true

  create_table "descriptions", :force => true do |t|
    t.integer  "feature_id",                    :null => false
    t.text     "content",                       :null => false
    t.boolean  "is_primary", :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "source_url"
  end

  create_table "feature_geo_codes", :force => true do |t|
    t.integer  "feature_id"
    t.integer  "geo_code_type_id"
    t.integer  "timespan_id"
    t.string   "geo_code_value"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feature_name_relations", :force => true do |t|
    t.integer  "child_node_id",                       :null => false
    t.integer  "parent_node_id",                      :null => false
    t.string   "ancestor_ids"
    t.integer  "is_phonetic",            :limit => 2
    t.integer  "is_orthographic",        :limit => 2
    t.integer  "is_translation",         :limit => 2
    t.integer  "is_alt_spelling",        :limit => 2
    t.integer  "phonetic_system_id"
    t.integer  "orthographic_system_id"
    t.integer  "alt_spelling_system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "feature_name_relations", ["child_node_id"], :name => "feature_name_relations_child_node_id_idx"
  add_index "feature_name_relations", ["parent_node_id"], :name => "feature_name_relations_parent_node_id_idx"

  create_table "feature_names", :force => true do |t|
    t.integer  "feature_id",                                     :null => false
    t.string   "name",                                           :null => false
    t.integer  "feature_name_type_id"
    t.string   "ancestor_ids"
    t.integer  "position",                    :default => 0
    t.text     "etymology"
    t.integer  "writing_system_id"
    t.integer  "language_id",                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_primary_for_romanization", :default => false
  end

  add_index "feature_names", ["ancestor_ids"], :name => "feature_names_ancestor_ids_idx"
  add_index "feature_names", ["feature_id"], :name => "feature_names_feature_id_idx"
  add_index "feature_names", ["name"], :name => "feature_names_name_idx"

  create_table "feature_relation_types", :force => true do |t|
    t.boolean  "is_symmetric"
    t.string   "label",                               :null => false
    t.string   "asymmetric_label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",                                :null => false
    t.boolean  "is_hierarchical",  :default => false, :null => false
    t.string   "asymmetric_code"
  end

  create_table "feature_relations", :force => true do |t|
    t.integer  "child_node_id",                          :null => false
    t.integer  "parent_node_id",                         :null => false
    t.string   "ancestor_ids"
    t.text     "notes"
    t.string   "role",                     :limit => 20
    t.integer  "perspective_id",                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "feature_relation_type_id",               :null => false
  end

  add_index "feature_relations", ["ancestor_ids"], :name => "feature_relations_ancestor_ids_idx"
  add_index "feature_relations", ["child_node_id"], :name => "feature_relations_child_node_id_idx"
  add_index "feature_relations", ["parent_node_id"], :name => "feature_relations_parent_node_id_idx"
  add_index "feature_relations", ["perspective_id"], :name => "feature_relations_perspective_id_idx"
  add_index "feature_relations", ["role"], :name => "feature_relations_role_idx"

  create_table "features", :force => true do |t|
    t.integer  "is_public",                  :limit => 2
    t.integer  "position",                                :default => 0
    t.string   "ancestor_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "old_pid"
    t.boolean  "is_blank",                                :default => false, :null => false
    t.integer  "fid",                                                        :null => false
    t.boolean  "is_name_position_overriden",              :default => false, :null => false
  end

  add_index "features", ["ancestor_ids"], :name => "features_ancestor_ids_idx"
  add_index "features", ["fid"], :name => "features_fid", :unique => true
  add_index "features", ["is_public"], :name => "features_is_public_idx"

  create_table "info_sources", :force => true do |t|
    t.string   "code",           :null => false
    t.string   "title"
    t.string   "agent"
    t.date     "date_published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "info_sources", ["code"], :name => "info_sources_code_key", :unique => true

  create_table "note_titles", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", :force => true do |t|
    t.string   "notable_type"
    t.integer  "notable_id"
    t.integer  "note_title_id"
    t.string   "custom_note_title"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "association_type"
    t.boolean  "is_public",         :default => true
  end

  create_table "pages", :force => true do |t|
    t.integer  "citation_id"
    t.integer  "volume"
    t.integer  "start_page"
    t.integer  "start_line"
    t.integer  "end_page"
    t.integer  "end_line"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.string "fullname", :null => false
  end

  add_index "people", ["fullname"], :name => "index_people_on_fullname", :unique => true

  create_table "permissions", :force => true do |t|
    t.string "title",       :limit => 60, :null => false
    t.text   "description"
  end

  add_index "permissions", ["title"], :name => "index_permissions_on_title", :unique => true

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "permission_id", :null => false
    t.integer "role_id",       :null => false
  end

  add_index "permissions_roles", ["permission_id", "role_id"], :name => "index_permissions_roles_on_permission_id_and_role_id", :unique => true

  create_table "perspectives", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.text     "description"
    t.text     "notes"
    t.boolean  "is_public",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "perspectives", ["code"], :name => "index_perspectives_on_code"

  create_table "roles", :force => true do |t|
    t.string "title",       :limit => 20, :null => false
    t.text   "description"
  end

  add_index "roles", ["title"], :name => "index_roles_on_title", :unique => true

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id", :null => false
    t.integer "user_id", :null => false
  end

  add_index "roles_users", ["role_id", "user_id"], :name => "index_roles_users_on_role_id_and_user_id", :unique => true

  create_table "shapes", :primary_key => "gid", :force => true do |t|
    t.geometry "geometry",   :limit => nil,                                   :srid => 4326
    t.integer  "fid"
    t.integer  "position",                  :default => 0,    :null => false
    t.float    "area"
    t.integer  "altitude"
    t.boolean  "is_public",                 :default => true, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shapes", ["fid"], :name => "shapes_fid"
  add_index "shapes", ["geometry"], :name => "features_geometry_gist", :spatial => true
  add_index "shapes", [], :name => "shapes_geotype"

  create_table "simple_props", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.text     "description"
    t.text     "notes"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_props", ["code"], :name => "simple_props_code_idx"
  add_index "simple_props", ["type"], :name => "simple_props_type_idx"

  create_table "time_units", :force => true do |t|
    t.integer  "date_id"
    t.integer  "start_date_id"
    t.integer  "end_date_id"
    t.integer  "calendar_id"
    t.boolean  "is_range"
    t.integer  "dateable_id"
    t.string   "dateable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "frequency_id"
  end

  create_table "timespans", :force => true do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "start_date_fuzz"
    t.integer  "end_date_fuzz"
    t.integer  "is_current",      :limit => 2
    t.integer  "dateable_id"
    t.string   "dateable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "timespans", ["dateable_id", "dateable_type"], :name => "timespans_1_idx"
  add_index "timespans", ["end_date"], :name => "timespans_end_date_idx"
  add_index "timespans", ["start_date"], :name => "timespans_start_date_idx"

  create_table "users", :force => true do |t|
    t.string   "login",                                   :null => false
    t.string   "email",                                   :null => false
    t.integer  "person_id",                               :null => false
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "identity_url"
    t.string   "shibboleth_id"
  end

  create_table "xml_documents", :force => true do |t|
    t.integer  "feature_id", :null => false
    t.text     "document",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "xml_documents", ["feature_id"], :name => "xml_documents_feature_id_idx"

end