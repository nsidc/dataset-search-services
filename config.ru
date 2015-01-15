require 'bundler'
require File.join(File.dirname(__FILE__), 'lib', 'nsidc_open_search', 'app')
require File.join(File.dirname(__FILE__), 'config', 'app_config')

Bundler.require :default

map AppConfig[ENV['RACK_ENV']][:relative_url_root] do
  run NsidcOpenSearch::App
end