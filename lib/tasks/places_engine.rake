namespace :places do
  desc "Syncronize extra files for Places Dictionary."
  task :sync do
    system "rsync -ruv --exclude '.*' vendor/plugins/places_engine/db/migrate db"
    system "rsync -ruv --exclude '.*' vendor/plugins/places_engine/public ."
  end  
end