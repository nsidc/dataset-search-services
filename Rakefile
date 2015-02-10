require 'bundler/setup'
require 'rspec/core/rake_task'
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
