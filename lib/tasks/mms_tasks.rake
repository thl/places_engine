namespace :places_engine do
  namespace :mms do
    desc 'Imports thumbnails from MMS'
    task :illustrations => :environment do |t|
      require File.join(File.dirname(__FILE__), '../places_engine/image_import.rb')
      ImageImport.do_image_import
    end
  end
end