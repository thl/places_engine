# Original file by Tobias Luetke, found on
#   http://blog.leetsoft.com/2006/5/29/easy-migration-between-databases
#
# set_sequences task by tnb@thenakedbrain.com
#
namespace :db do
  namespace :backup do
    def interesting_tables
      ActiveRecord::Base.connection.tables.sort.reject! do |tbl|
        ['schema_info', 'sessions', 'logged_exceptions'].include?(tbl)
      end
    end
    desc "Dump entire db."
    task :write => :environment do 
      dir = Rails.root.join('db', 'backup')
      FileUtils.mkdir_p(dir)
      FileUtils.chdir(dir)
      interesting_tables.each do |tbl|
        begin
          klass = tbl.classify.constantize
          puts "Writing #{tbl}..."
          File.open("#{tbl}.yml", 'w+') { |f| YAML.dump klass.find(:all).collect(&:attributes), f }
        rescue
          puts "Skipping #{tbl}"
        end
      end
    end
    task :read => [:environment, 'db:schema:load'] do
      dir = Rails.root.join('db', 'backup')
      FileUtils.mkdir_p(dir)
      FileUtils.chdir(dir)
      interesting_tables.each do |tbl|
        klass = tbl.classify.constantize
        ActiveRecord::Base.transaction do
          puts "Loading #{tbl}..."
          YAML.load_file("#{tbl}.yml").each do |fixture|
            ActiveRecord::Base.connection.execute "INSERT INTO #{tbl} (#{fixture.keys.join(",")}) VALUES (#{fixture.values.collect { |value| ActiveRecord::Base.connection.quote(value) }.join(",")})", 'Fixture Insert'
          end
        end
      end
    end
    desc "Set postgresql sequence currval to highest id for each table"
    task :set_sequences => :environment do
      if ActiveRecord::Base.connection.adapter_name.downcase == "postgresql"
        interesting_tables.each do |tbl|
          puts "Setting sequence's currval to highest id for #{tbl}"
          ActiveRecord::Base.connection.execute "select setval('#{tbl}_id_seq', (select max(id) from #{tbl}));"
        end
      else
        puts "This operation only works for postgresql databases."
      end
    end
  end
end