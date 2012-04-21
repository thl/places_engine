# Include hook code here
# require 'postgres_patch' CHECKING IF THIS IS NO LONGER NEEDED
require 'active_record_ext'
require 'array_ext'
require 'will_paginate_ext'
require 'csv'
require File.join(File.dirname(__FILE__), 'app', 'sweepers', 'cached_category_count_sweeper')
require File.join(File.dirname(__FILE__), 'app', 'sweepers', 'feature_sweeper')
require File.join(File.dirname(__FILE__), 'app', 'sweepers', 'description_sweeper')
I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config', 'locales', '**', '*.yml')]
CachedCategoryCountSweeper.instance