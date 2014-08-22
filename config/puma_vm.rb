#!/usr/bin/env puma
require File.join(File.dirname(__FILE__), 'app_config.rb')

# Puma configuration file. See https://github.com/puma/puma for more information and example config files.
directory '/opt/search_services'
env = "#{ENV['RACK_ENV']}" || 'development'

rackup '/opt/search_services/config.ru'
bind "tcp://0.0.0.0:#{AppConfig[env][:port]}"
pidfile AppConfig[env][:pidfile]
state_path AppConfig[env][:state_path]
threads 1, 1 # min, max
workers AppConfig[env][:num_workers]
environment env
# STDOUT, STDERR, append
stdout_redirect AppConfig[env][:std_err_log], AppConfig[env][:std_out_log], true
