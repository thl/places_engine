namespace :railroad do
  
  desc 'Generates a model relationship png'
  task :models=>:environment do
    `railroad -M -a -i -j -m -t | dot -Tpng > models.png`
  end
  
end