require 'config/environment'
namespace :places do
  namespace :mms do
    desc "Deploys sources to MMS documents (authenticating through MMS_USER argument) making the appropriate replacements."
    task :deploy_sources do |t|
      require File.join(File.dirname(__FILE__), "../lib/mms_deployer.rb")
      MediaManagementResource.user = ENV['MMS_USER']
      if !MediaManagementResource.user.blank?
        puts "Password for #{MediaManagementResource.user}:"
        MediaManagementResource.password = STDIN.gets.chomp
        MediaManagementDeployer.do_source_deployment
      else
        puts 'User and password needed! Use MMS_USER= to set user from command-line.'
      end
    end
  end
end