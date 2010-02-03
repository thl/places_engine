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

ActiveRecord::Schema.define(:version => 20091110192155) do

  create_table "authors_descriptions", :id => false, :force => true do |t|
    t.column "author_id", :integer, :null => false
    t.column "description_id", :integer, :null => false
  end

  add_index "authors_descriptions", ["author_id", "description_id"], :name => "index_authors_descriptions_on_author_id_and_description_id", :unique => true

  create_table "blurbs", :force => true do |t|
    t.column "code", :string
    t.column "title", :string
    t.column "content", :text
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  create_table "cached_category_counts", :force => true do |t|
    t.column "category_id", :integer, :null => false
    t.column "count", :integer, :null => false
    t.column "cache_updated_at", :timestamp, :null => false
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "cached_category_counts", ["category_id"], :name => "index_cached_category_counts_on_category_id", :unique => true

  create_table "cached_feature_names", :force => true do |t|
    t.column "feature_id", :integer, :null => false
    t.column "view_id", :integer, :null => false
    t.column "feature_name_id", :integer
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "cached_feature_names", ["feature_id", "view_id"], :name => "index_cached_feature_names_on_feature_id_and_view_id", :unique => true

  create_table "citations", :force => true do |t|
    t.column "info_source_id", :integer
    t.column "citable_type", :string
    t.column "citable_id", :integer
    t.column "pages", :string
    t.column "notes", :text
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "citations", ["citable_type", "citable_id"], :name => "citations_1_idx"
  add_index "citations", ["info_source_id"], :name => "citations_info_source_id_idx"

  create_table "contestations", :force => true do |t|
    t.column "feature_id", :integer, :null => false
    t.column "contested", :boolean, :default => true, :null => false
    t.column "administrator_id", :integer
    t.column "claimant_id", :integer
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  create_table "cumulative_category_feature_associations", :force => true do |t|
    t.column "feature_id", :integer, :null => false
    t.column "category_id", :integer, :null => false
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "cumulative_category_feature_associations", ["feature_id", "category_id"], :name => "by_category_feature", :unique => true

  create_table "descriptions", :force => true do |t|
    t.column "feature_id", :integer, :null => false
    t.column "content", :text, :null => false
    t.column "is_primary", :boolean, :default => false, :null => false
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "title", :string
  end

  create_table "feature_geo_codes", :force => true do |t|
    t.column "feature_id", :integer
    t.column "geo_code_type_id", :integer
    t.column "timespan_id", :integer
    t.column "geo_code_value", :string
    t.column "notes", :text
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  create_table "feature_name_relations", :force => true do |t|
    t.column "child_node_id", :integer, :null => false
    t.column "parent_node_id", :integer, :null => false
    t.column "ancestor_ids", :string
    t.column "is_phonetic", :integer
    t.column "is_orthographic", :integer
    t.column "is_translation", :integer
    t.column "is_alt_spelling", :integer
    t.column "phonetic_system_id", :integer
    t.column "orthographic_system_id", :integer
    t.column "alt_spelling_system_id", :integer
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "feature_name_relations", ["child_node_id"], :name => "feature_name_relations_child_node_id_idx"
  add_index "feature_name_relations", ["parent_node_id"], :name => "feature_name_relations_parent_node_id_idx"

  create_table "feature_names", :force => true do |t|
    t.column "feature_id", :integer, :null => false
    t.column "name", :string, :null => false
    t.column "feature_name_type_id", :integer
    t.column "ancestor_ids", :string
    t.column "position", :integer, :default => 0
    t.column "etymology", :text
    t.column "writing_system_id", :integer
    t.column "language_id", :integer, :null => false
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "is_primary_for_romanization", :boolean, :default => false
  end

  add_index "feature_names", ["ancestor_ids"], :name => "feature_names_ancestor_ids_idx"
  add_index "feature_names", ["feature_id"], :name => "feature_names_feature_id_idx"
  add_index "feature_names", ["name"], :name => "feature_names_name_idx"

  create_table "feature_object_types", :force => true do |t|
    t.column "feature_id", :integer, :null => false
    t.column "object_type_id", :integer, :null => false
    t.column "perspective_id", :integer
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "position", :integer, :default => 0, :null => false
  end

  add_index "feature_object_types", ["feature_id"], :name => "feature_object_types_feature_id_idx"
  add_index "feature_object_types", ["object_type_id"], :name => "feature_object_types_object_type_id_idx"
  add_index "feature_object_types", ["perspective_id"], :name => "feature_object_types_perspective_id_idx"

  create_table "feature_relations", :force => true do |t|
    t.column "child_node_id", :integer, :null => false
    t.column "parent_node_id", :integer, :null => false
    t.column "ancestor_ids", :string
    t.column "notes", :text
    t.column "role", :string, :limit => 20
    t.column "perspective_id", :integer, :null => false
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "feature_relations", ["ancestor_ids"], :name => "feature_relations_ancestor_ids_idx"
  add_index "feature_relations", ["child_node_id"], :name => "feature_relations_child_node_id_idx"
  add_index "feature_relations", ["parent_node_id"], :name => "feature_relations_parent_node_id_idx"
  add_index "feature_relations", ["perspective_id"], :name => "feature_relations_perspective_id_idx"
  add_index "feature_relations", ["role"], :name => "feature_relations_role_idx"

  create_table "features", :force => true do |t|
    t.column "is_public", :integer
    t.column "position", :integer, :default => 0
    t.column "ancestor_ids", :string
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "old_pid", :string
    t.column "is_blank", :boolean, :default => false, :null => false
    t.column "fid", :integer, :null => false
    t.column "is_name_position_overriden", :boolean, :default => false, :null => false
  end

  add_index "features", ["ancestor_ids"], :name => "features_ancestor_ids_idx"
  add_index "features", ["fid"], :name => "features_fid", :unique => true
  add_index "features", ["is_public"], :name => "features_is_public_idx"

  create_table "info_sources", :force => true do |t|
    t.column "code", :string, :null => false
    t.column "title", :string
    t.column "agent", :string
    t.column "date_published", :date
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "info_sources", ["code"], :name => "info_sources_code_key", :unique => true

# Could not dump table "open_id_authentication_associations" because of following StandardError
#   Unknown type 'bytea' for column 'server_url' /Users/amontano/Workspaces/rails/trunk/places/vendor/plugins/spatial_adapter/lib/common_spatial_adapter.rb:44:in `table'/Users/amontano/Workspaces/rails/trunk/places/vendor/plugins/spatial_adapter/lib/common_spatial_adapter.rb:42:in `each'/Users/amontano/Workspaces/rails/trunk/places/vendor/plugins/spatial_adapter/lib/common_spatial_adapter.rb:42:in `table'/Users/amontano/Workspaces/rails/trunk/places/vendor/rails/activerecord/lib/active_record/schema_dumper.rb:72:in `tables'/Users/amontano/Workspaces/rails/trunk/places/vendor/rails/activerecord/lib/active_record/schema_dumper.rb:63:in `each'/Users/amontano/Workspaces/rails/trunk/places/vendor/rails/activerecord/lib/active_record/schema_dumper.rb:63:in `tables'/Users/amontano/Workspaces/rails/trunk/places/vendor/rails/activerecord/lib/active_record/schema_dumper.rb:25:in `dump'/Users/amontano/Workspaces/rails/trunk/places/vendor/rails/activerecord/lib/active_record/schema_dumper.rb:19:in `dump'/Users/amontano/Workspaces/rails/trunk/places/vendor/rails/railties/lib/tasks/databases.rake:260/Users/amontano/Workspaces/rails/trunk/places/vendor/rails/railties/lib/tasks/databases.rake:259:in `open'/Users/amontano/Workspaces/rails/trunk/places/vendor/rails/railties/lib/tasks/databases.rake:259/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:636:in `call'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:636:in `execute'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:631:in `each'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:631:in `execute'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:597:in `invoke_with_call_chain'/opt/local/lib/ruby/1.8/monitor.rb:242:in `synchronize'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:590:in `invoke_with_call_chain'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:583:in `invoke'/Users/amontano/Workspaces/rails/trunk/places/vendor/rails/railties/lib/tasks/databases.rake:117/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:636:in `call'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:636:in `execute'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:631:in `each'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:631:in `execute'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:597:in `invoke_with_call_chain'/opt/local/lib/ruby/1.8/monitor.rb:242:in `synchronize'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:590:in `invoke_with_call_chain'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:583:in `invoke'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2051:in `invoke_task'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2029:in `top_level'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2029:in `each'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2029:in `top_level'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2068:in `standard_exception_handling'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2023:in `top_level'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2001:in `run'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2068:in `standard_exception_handling'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:1998:in `run'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/bin/rake:31/opt/local/bin/rake:19:in `load'/opt/local/bin/rake:19

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.column "timestamp", :integer, :null => false
    t.column "server_url", :string, :null => false
    t.column "salt", :string, :null => false
  end

  create_table "perspectives", :force => true do |t|
    t.column "name", :string
    t.column "code", :string
    t.column "description", :text
    t.column "notes", :text
    t.column "is_public", :boolean, :default => false
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "perspectives", ["code"], :name => "index_perspectives_on_code"

  create_table "shapes", :primary_key => "gid", :force => true do |t|
    t.column "geometry", :geometry, :srid => 4326
    t.column "fid", :integer
    t.column "position", :integer, :default => 0, :null => false
  end

  add_index "shapes", ["geometry"], :name => "features_geometry_gist", :spatial=> true 
  add_index "shapes", ["fid"], :name => "shapes_fid"

  create_table "simple_props", :force => true do |t|
    t.column "name", :string
    t.column "code", :string
    t.column "description", :text
    t.column "notes", :text
    t.column "type", :string
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "simple_props", ["code"], :name => "simple_props_code_idx"
  add_index "simple_props", ["type"], :name => "simple_props_type_idx"

  create_table "test2", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => 4326
  end

  create_table "timespans", :force => true do |t|
    t.column "start_date", :date
    t.column "end_date", :date
    t.column "start_date_fuzz", :integer
    t.column "end_date_fuzz", :integer
    t.column "is_current", :integer
    t.column "dateable_id", :integer
    t.column "dateable_type", :string
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "timespans", ["dateable_id", "dateable_type"], :name => "timespans_1_idx"
  add_index "timespans", ["end_date"], :name => "timespans_end_date_idx"
  add_index "timespans", ["start_date"], :name => "timespans_start_date_idx"

  create_table "users", :force => true do |t|
    t.column "login", :string, :null => false
    t.column "email", :string, :null => false
    t.column "person_id", :integer
    t.column "crypted_password", :string, :limit => 40, :null => false
    t.column "salt", :string, :limit => 40
    t.column "remember_token", :string
    t.column "remember_token_expires_at", :timestamp
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "identity_url", :string
    t.column "fullname", :string
  end

  create_table "xml_documents", :force => true do |t|
    t.column "feature_id", :integer, :null => false
    t.column "document", :text, :null => false
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "xml_documents", ["feature_id"], :name => "xml_documents_feature_id_idx"

end
