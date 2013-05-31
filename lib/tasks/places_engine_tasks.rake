namespace :places_engine do
  namespace :db do
    namespace :schema do
      desc "Load schema for places engine tables"
      task :load do
        ENV['SCHEMA'] = File.join(PlacesEngine::Engine.paths['db'].existent.first, 'schema.rb')
        Rake::Task['db:schema:load'].invoke
      end
    end
  end
end