# Include hook code here
require 'postgres_patch'
require 'active_record_ext'
require 'array_ext'
require 'will_paginate_ext'
require 'csv'
require File.join(File.dirname(__FILE__), 'app', 'sweepers', 'cached_category_count_sweeper')
require File.join(File.dirname(__FILE__), 'app', 'sweepers', 'feature_sweeper')
CachedCategoryCountSweeper.instance