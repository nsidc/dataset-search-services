require 'bundler/setup'
require 'rspec/core/rake_task'
require 'nsidc_deployment_helper'
require 'nsidc_deployment_helper/jetty'
require 'nsidc_deployment_helper/setup_auth_agents'
require 'nsidc_deployment_helper/deployment_log'
require 'nsidc_deployment_helper/tar_artifact'
require File.join('.', 'config', 'deployment_config.rb')
require File.join('.', 'config', 'app_config.rb')
require File.join('.', 'lib', 'version.rb')

Dir.glob('./tasks/*.rake').each { |r| import r }

# Immediately sync all stdout so that tools like buildbot can
# immediately load in the output.
$stdout.sync = true
$stderr.sync = true

# Change to the directory of this file.
Dir.chdir(File.expand_path('../', __FILE__))

desc 'Run local webserver instance'
task :run do
  # require gems here to avoid conflicts between rake and sinatra-contrib
  Bundler.require(:default)

  # The following line should enable an ssl connection, but it currently doesn't work https://github.com/puma/puma/issues/522
  # sh 'puma -b ssl://0.0.0.0:3000\?key=/home/vagrant/tmp/cert/server.key\&cert=/home/vagrant/tmp/cert/server.csr -t 1:1 -w 5 -e development -C "-"'

  sh 'puma -b tcp://0.0.0.0:3000 -t 1:1 -w 5 -e development -C "-"'
end

desc 'List all routes'
task :routes do
  # Figure out how to Get this path from the environment
  # rather than hardcoding!
  app_dir = 'lib/nsidc_open_search'
  require ['.', app_dir, 'app.rb'].join('/')
  root_path = [File.expand_path('../', __FILE__), app_dir].join('/')

  NsidcOpenSearch::App.each_route do |r|
    print r.verb.ljust(12)
    print r.path.ljust(35) unless r.path.nil?
    unless r.file.nil?
      r.file.slice! root_path unless r.file.nil?
      print "#{r.file} (#{r.line})"
    end
    puts ''
  end
end

task default: 'spec:unit'

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.rspec_opts = %w[-f progress -f JUnit -o results.xml]
  end

  RSpec::Core::RakeTask.new(:acceptance) do |t|
    t.rspec_opts = %w[-f progress -f RSpecTurnipFormatter -o results.html -f JUnit -o results.xml]
    t.pattern = './spec/acceptance/**/*{.feature}'
  end
end

def run_vagrant_ssh(env, ssh_cmd)
  cmd = "vagrant nsidc ssh --env=#{env} -c '#{ssh_cmd}'"
  puts "Running #{cmd}"

  `#{ cmd }`
end

# Do some file system manipulation to make sure that the app exists in
# the app path, and that puma is ready to configure and start up.
task :setup_machine, [:env] do |_t, args|
  run_vagrant_ssh(args[:env], "sudo mkdir -p #{ AppConfig::APP_PATH }")
  run_vagrant_ssh(args[:env], "sudo cp -R /vagrant/* #{ AppConfig::APP_PATH }")
  run_vagrant_ssh(args[:env], "sudo chown -R vagrant #{ AppConfig::APP_PATH }")
end

task :configure_puma, [:env] do |_t, args|
  puma_config = File.join(AppConfig::APP_PATH, 'deployment/puma.conf')

  run_vagrant_ssh(args[:env], "sudo echo #{AppConfig::APP_PATH}/config.ru > /etc/puma.conf")
  run_vagrant_ssh(args[:env], "sudo cp #{puma_config} /etc/init/")
  run_vagrant_ssh(args[:env], "mkdir -p #{File.join(AppConfig::APP_PATH, 'run/log')}")
  run_vagrant_ssh(args[:env], "sudo chown vagrant #{File.join(AppConfig::APP_PATH, 'config')}")
  run_vagrant_ssh(args[:env], "echo '#{args[:env]}' > #{File.join(AppConfig::APP_PATH, 'config/environment')}")
end
task configure_puma: :setup_machine

task :start_puma, [:env] do |_t, args|
  run_vagrant_ssh(args[:env], 'sudo service puma start')
end
task start_puma: :configure_puma
