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

ActiveRecord::Schema.define(:version => 20100521170006) do

  create_table "Birth_rate", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "pop_total", :float
    t.column "births_199", :float
    t.column "rate", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Births_and_deaths", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "births_1990", :float
    t.column "deaths_1990", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Death_rate", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "pop_total", :float
    t.column "death_1990", :float
    t.column "rate", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Economical_activity", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "agriculture", :float
    t.column "industry", :float
    t.column "mining", :float
    t.column "constructio", :float
    t.column "government_", :float
    t.column "other", :integer
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Ethnic_distribution", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "population_", :float
    t.column "Han", :float
    t.column "Tibetans", :float
    t.column "Mongols", :float
    t.column "Hui", :float
    t.column "other", :integer
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Han_rate", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "pop_total", :float
    t.column "pop_han", :float
    t.column "rate", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Illiteracy_per_gender", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "pop_total", :float
    t.column "illit_male", :float
    t.column "illit_fem", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Illiteracy_rate", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "pop_total", :float
    t.column "pop_illet", :float
    t.column "rate", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Immigration_rate", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "pop_total", :integer
    t.column "immig", :float
    t.column "rate", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Population_density", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "pop_total", :float
    t.column "sq_km", :float
    t.column "density", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Population_per_gender", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "males_1990", :float
    t.column "females_199", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "Tibetan_rate", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "pop_total", :float
    t.column "pop_tib", :float
    t.column "rate", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "authors_descriptions", :id => false, :force => true do |t|
    t.column "author_id", :integer, :null => false
    t.column "description_id", :integer, :null => false
  end

  add_index "authors_descriptions", ["author_id", "description_id"], :name => "index_authors_descriptions_on_author_id_and_description_id", :unique => true

  create_table "authors_notes", :id => false, :force => true do |t|
    t.column "author_id", :integer, :null => false
    t.column "note_id", :integer, :null => false
  end

  add_index "authors_notes", ["author_id", "note_id"], :name => "index_authors_notes_on_author_id_and_note_id", :unique => true

  create_table "bbox", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "bbox_test", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "bellezza", :primary_key => "gid", :force => true do |t|
    t.column "objectid", :integer
    t.column "sort_no", :decimal
    t.column "type", :string, :limit => 254
    t.column "site_no", :string, :limit => 254
    t.column "name_wylie", :string, :limit => 254
    t.column "name_eng", :string, :limit => 254
    t.column "county", :string, :limit => 254
    t.column "the_geom", :point, :srid => 4326
  end

  add_index "bellezza", ["the_geom"], :name => "bellezza_geom", :spatial=> true 

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

  create_table "cached_feature_relation_categories", :force => true do |t|
    t.column "feature_id", :integer
    t.column "related_feature_id", :integer
    t.column "category_id", :integer
    t.column "perspective_id", :integer
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "feature_relation_type_id", :integer
    t.column "feature_is_parent", :boolean
  end

  create_table "category_features", :force => true do |t|
    t.column "feature_id", :integer, :null => false
    t.column "category_id", :integer, :null => false
    t.column "perspective_id", :integer
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "position", :integer, :default => 0, :null => false
    t.column "type", :string
    t.column "string_value", :string
    t.column "numeric_value", :integer
  end

  add_index "category_features", ["feature_id"], :name => "feature_object_types_feature_id_idx"
  add_index "category_features", ["category_id"], :name => "feature_object_types_object_type_id_idx"
  add_index "category_features", ["perspective_id"], :name => "feature_object_types_perspective_id_idx"

  create_table "citations", :force => true do |t|
    t.column "info_source_id", :integer
    t.column "citable_type", :string
    t.column "citable_id", :integer
    t.column "notes", :text
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "citations", ["citable_type", "citable_id"], :name => "citations_1_idx"
  add_index "citations", ["info_source_id"], :name => "citations_info_source_id_idx"

  create_table "complex_dates", :force => true do |t|
    t.column "year", :integer
    t.column "year_certainty_id", :integer
    t.column "season_id", :integer
    t.column "season_certainty_id", :integer
    t.column "month", :integer
    t.column "month_certainty_id", :integer
    t.column "day", :integer
    t.column "day_certainty_id", :integer
    t.column "day_of_week_id", :integer
    t.column "day_of_week_certainty_id", :integer
    t.column "time_of_day_id", :integer
    t.column "time_of_day_certainty_id", :integer
    t.column "hour", :integer
    t.column "hour_certainty_id", :integer
    t.column "minute", :integer
    t.column "minute_certainty_id", :integer
    t.column "animal_id", :integer
    t.column "animal_certainty_id", :integer
    t.column "calendrical_id", :integer
    t.column "calendrical_certainty_id", :integer
    t.column "element_certainty_id", :integer
    t.column "element_id", :integer
    t.column "gender_id", :integer
    t.column "gender_certainty_id", :integer
    t.column "intercalary_month_id", :integer
    t.column "intercalary_day_id", :integer
    t.column "rabjung_id", :integer
    t.column "rabjung_certainty_id", :integer
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "year_end", :integer
    t.column "season_end_id", :integer
    t.column "month_end", :integer
    t.column "day_end", :integer
    t.column "day_of_week_end_id", :integer
    t.column "time_of_day_end_id", :integer
    t.column "hour_end", :integer
    t.column "minute_end", :integer
    t.column "rabjung_end_id", :integer
    t.column "intercalary_month_end_id", :integer
    t.column "intercalary_day_end_id", :integer
  end

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

  create_table "devanagari_poly", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "devanagari_pt", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "electricity_use_10_million_watt_hours", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "elect_use", :float
    t.column "the_geom", :polygon, :srid => 4326
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

  create_table "feature_relation_types", :force => true do |t|
    t.column "is_symmetric", :boolean
    t.column "label", :string
    t.column "asymmetric_label", :string
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  create_table "feature_relations", :force => true do |t|
    t.column "child_node_id", :integer, :null => false
    t.column "parent_node_id", :integer, :null => false
    t.column "ancestor_ids", :string
    t.column "notes", :text
    t.column "role", :string, :limit => 20
    t.column "perspective_id", :integer, :null => false
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "feature_relation_type_id", :integer
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

  create_table "fontdemo", :primary_key => "gid", :force => true do |t|
    t.column "font", :string, :limit => 50
    t.column "text", :string, :limit => 100
    t.column "x", :float
    t.column "y", :float
    t.column "geometry", :point, :srid => 4326
  end

  create_table "grain_output_tons", :id => false, :force => true do |t|
    t.column "gid", :integer, :null => false
    t.column "name", :string, :limit => 27
    t.column "output_tons", :float
    t.column "the_geom", :polygon, :srid => 4326
  end

  create_table "illiteracy_per_gender", :id => false, :force => true do |t|
    t.column "name", :text
    t.column "pop_total", :float
    t.column "illit_male", :float
    t.column "illit_fem", :float
    t.column "geometry", :geometry, :srid => 4326
  end

  create_table "info_sources", :force => true do |t|
    t.column "code", :string, :null => false
    t.column "title", :string
    t.column "agent", :string
    t.column "date_published", :date
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  add_index "info_sources", ["code"], :name => "info_sources_code_key", :unique => true

  create_table "landcover", :primary_key => "gid", :force => true do |t|
    t.column "type", :string, :limit => 40
    t.column "the_geom", :geometry, :srid => nil
  end

  add_index "landcover", ["the_geom"], :name => "landcover_geom", :spatial=> true 

  create_table "maketest2", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string, :limit => nil
    t.column "name", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "note_titles", :force => true do |t|
    t.column "title", :string
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
  end

  create_table "notes", :force => true do |t|
    t.column "notable_type", :string
    t.column "notable_id", :integer
    t.column "note_title_id", :integer
    t.column "custom_note_title", :string
    t.column "content", :text
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
    t.column "association_type", :string
  end

# Could not dump table "open_id_authentication_associations" because of following StandardError
#   Unknown type 'bytea' for column 'server_url' /Users/amontano/Workspaces/rails/master/places/vendor/plugins/spatial_adapter/lib/common_spatial_adapter.rb:44:in `table'/Users/amontano/Workspaces/rails/master/places/vendor/plugins/spatial_adapter/lib/common_spatial_adapter.rb:42:in `each'/Users/amontano/Workspaces/rails/master/places/vendor/plugins/spatial_adapter/lib/common_spatial_adapter.rb:42:in `table'/Users/amontano/Workspaces/rails/master/places/vendor/rails/activerecord/lib/active_record/schema_dumper.rb:72:in `tables'/Users/amontano/Workspaces/rails/master/places/vendor/rails/activerecord/lib/active_record/schema_dumper.rb:63:in `each'/Users/amontano/Workspaces/rails/master/places/vendor/rails/activerecord/lib/active_record/schema_dumper.rb:63:in `tables'/Users/amontano/Workspaces/rails/master/places/vendor/rails/activerecord/lib/active_record/schema_dumper.rb:25:in `dump'/Users/amontano/Workspaces/rails/master/places/vendor/rails/activerecord/lib/active_record/schema_dumper.rb:19:in `dump'/Users/amontano/Workspaces/rails/master/places/vendor/rails/railties/lib/tasks/databases.rake:260/Users/amontano/Workspaces/rails/master/places/vendor/rails/railties/lib/tasks/databases.rake:259:in `open'/Users/amontano/Workspaces/rails/master/places/vendor/rails/railties/lib/tasks/databases.rake:259/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:636:in `call'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:636:in `execute'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:631:in `each'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:631:in `execute'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:597:in `invoke_with_call_chain'/opt/local/lib/ruby/1.8/monitor.rb:242:in `synchronize'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:590:in `invoke_with_call_chain'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:583:in `invoke'/Users/amontano/Workspaces/rails/master/places/vendor/rails/railties/lib/tasks/databases.rake:117/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:636:in `call'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:636:in `execute'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:631:in `each'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:631:in `execute'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:597:in `invoke_with_call_chain'/opt/local/lib/ruby/1.8/monitor.rb:242:in `synchronize'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:590:in `invoke_with_call_chain'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:583:in `invoke'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2051:in `invoke_task'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2029:in `top_level'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2029:in `each'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2029:in `top_level'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2068:in `standard_exception_handling'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2023:in `top_level'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2001:in `run'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:2068:in `standard_exception_handling'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/lib/rake.rb:1998:in `run'/opt/local/lib/ruby/gems/1.8/gems/rake-0.8.7/bin/rake:31/opt/local/bin/rake:19:in `load'/opt/local/bin/rake:19

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.column "timestamp", :integer, :null => false
    t.column "server_url", :string, :null => false
    t.column "salt", :string, :null => false
  end

  create_table "pages", :force => true do |t|
    t.column "citation_id", :integer
    t.column "volume", :integer
    t.column "start_page", :integer
    t.column "start_line", :integer
    t.column "end_page", :integer
    t.column "end_line", :integer
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
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

  create_table "points_only", :id => false, :force => true do |t|
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string, :limit => nil
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
    t.column "gid", :integer
  end

  create_table "roman_popular", :primary_key => "gid", :force => true do |t|
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  add_index "roman_popular", ["fid"], :name => "roman_popular_fid"
  add_index "roman_popular", ["geometry"], :name => "roman_popular_gist", :spatial=> true 
  add_index "roman_popular", ["language"], :name => "roman_popular_language"
  add_index "roman_popular", ["object_type"], :name => "roman_popular_object_type"

  create_table "roman_popular_bbox", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "roman_popular_poly", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "roman_popular_poly_low_res", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "simplify", :geometry, :srid => nil
  end

  create_table "roman_popular_poly_med_res", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "simplify", :geometry, :srid => nil
  end

  create_table "roman_popular_pt", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "roman_scholarly", :primary_key => "gid", :force => true do |t|
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  add_index "roman_scholarly", ["fid"], :name => "roman_scholarly_fid"
  add_index "roman_scholarly", ["geometry"], :name => "roman_scholarly_gist", :spatial=> true 
  add_index "roman_scholarly", ["language"], :name => "roman_scholarly_language"
  add_index "roman_scholarly", ["object_type"], :name => "roman_scholarly_object_type"

  create_table "roman_scholarly_poly", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "roman_scholarly_pt", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "shapes", :primary_key => "gid", :force => true do |t|
    t.column "geometry", :geometry, :srid => 4326
    t.column "fid", :integer
    t.column "position", :integer, :default => 0, :null => false
  end

  add_index "shapes", ["geometry"], :name => "features_geometry_gist", :spatial=> true 
  add_index "shapes", ["fid"], :name => "shapes_fid"

  create_table "simple_chinese", :primary_key => "gid", :force => true do |t|
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  add_index "simple_chinese", ["fid"], :name => "simple_chinese_fid"
  add_index "simple_chinese", ["geometry"], :name => "simple_chinese_gist", :spatial=> true 
  add_index "simple_chinese", ["language"], :name => "simple_chinese_language"
  add_index "simple_chinese", ["object_type"], :name => "simple_chinese_object_type"

  create_table "simple_chinese_poly", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "simple_chinese_pt", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

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
    t.column "gid", :integer, :null => false
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => 4326
  end

  add_index "test2", ["fid"], :name => "test2_fid"
  add_index "test2", ["geometry"], :name => "test2_gist", :spatial=> true 
  add_index "test2", ["language"], :name => "test2_language"
  add_index "test2", ["object_type"], :name => "test2_object_type"

  create_table "tibetan_chinese", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "tibetan_chinese_poly", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string, :limit => nil
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "tibetan_chinese_pt", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string, :limit => nil
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "tibetan_roman", :primary_key => "gid", :force => true do |t|
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  add_index "tibetan_roman", ["language"], :name => "tibetan_roman_language"
  add_index "tibetan_roman", ["object_type"], :name => "tibetan_roman_object_type"

  create_table "tibetan_roman_poly", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string, :limit => nil
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "tibetan_roman_pt", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string, :limit => nil
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "tibetan_test_poly", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string, :limit => nil
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "tibetan_test_pt", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string, :limit => nil
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "time_units", :force => true do |t|
    t.column "date_id", :integer
    t.column "start_date_id", :integer
    t.column "end_date_id", :integer
    t.column "calendar_id", :integer
    t.column "is_range", :boolean
    t.column "dateable_id", :integer
    t.column "dateable_type", :string
    t.column "created_at", :timestamp
    t.column "updated_at", :timestamp
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

  create_table "traditional_chinese", :primary_key => "gid", :force => true do |t|
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  add_index "traditional_chinese", ["fid"], :name => "traditional_chinese_fid"
  add_index "traditional_chinese", ["geometry"], :name => "traditional_chinese_gist", :spatial=> true 
  add_index "traditional_chinese", ["language"], :name => "traditional_chinese_language"
  add_index "traditional_chinese", ["object_type"], :name => "traditional_chinese_object_type"

  create_table "traditional_chinese_poly", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "traditional_chinese_pt", :id => false, :force => true do |t|
    t.column "gid", :integer
    t.column "fid", :integer
    t.column "object_type", :integer
    t.column "language", :string
    t.column "name", :string
    t.column "writing", :string
    t.column "geotype", :text
    t.column "geometry", :geometry, :srid => nil
  end

  create_table "trtibet", :id => false, :force => true do |t|
    t.column "pc", :string, :limit => 1
    t.column "std", :string, :limit => 7
  end

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
