# require 'config/environment'
require 'places_engine/import/feature_importation'

namespace :db do
  namespace :import do
    csv_desc = "Use to import CSV containing features into DB.\n" +
      "Syntax: rake db:import:features SOURCE=csv_file_name TASK=task_code [FROM=row_num] [TO=row_num] [LOG_LEVEL=0..5]"
    desc csv_desc
    task :features => :environment do
      source = ENV['SOURCE']
      task = ENV['TASK']
      from = ENV['FROM']
      to = ENV['TO']
      log_level = ENV['LOG_LEVEL']
      if source.blank? || task.blank?
        puts csv_desc
      else
        PlacesEngine::FeatureImportation.new("log/import_#{task}_#{Rails.env}.log", log_level.nil? ? Rails.logger.level : log_level.to_i).do_feature_import(filename: source, task_code: task, from: from, to: to)
      end
    end
  end
end
