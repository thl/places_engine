# Include hook code here
require 'postgres_patch'
require File.join(File.dirname(__FILE__), 'app', 'sweepers', 'cached_category_count_sweeper')
require 'active_record_ext'
require 'array_ext'
require 'will_paginate_ext'
require 'csv'
