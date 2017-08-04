# require 'config/environment'
require 'places_engine/import/feature_importation'

namespace :db do
  namespace :import do
    csv_desc = "Use to import CSV containing features into DB.\n" +
                  "Syntax: rake db:import:features SOURCE=csv-file-name TASK=task_code [FROM=row num] [TO=row num]"
    desc csv_desc
    task :features => :environment do
      source = ENV['SOURCE']
      task = ENV['TASK']
      from = ENV['FROM']
      to = ENV['TO']
      if source.blank? || task.blank?
        puts csv_desc
      else
        PlacesEngine::FeatureImportation.new.do_feature_import(source, task, from, to)
      end
    end
  end
end