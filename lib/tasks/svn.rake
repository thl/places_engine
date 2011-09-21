namespace :svn do

  desc "Add all new files to subversion"
  task :add do
     system "svn status | grep '^\?' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn add"
  end

end