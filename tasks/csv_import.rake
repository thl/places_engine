require 'config/environment'
namespace :db do
  namespace :import do
    csv_desc = "Use to import CSV containing features into DB.\n" +
                  "Syntax: rake db:import:csv SOURCE=csv-file-name"

    desc csv_desc
    task :csv do
      source = ENV['SOURCE']
      if source.blank?
        puts csv_desc
      else
        Importation.do_csv_import(source)
      end
    end
  end
end