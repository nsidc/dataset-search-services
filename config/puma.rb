#!/usr/bin/env puma
require File.join(File.dirname(__FILE__), 'app_config')

# Puma configuration file. See https://github.com/puma/puma for more information and example config files.

env = "#{ENV['RACK_ENV']}" || 'development'

rackup '/live/apps/dataset-search-services/webapps/dataset-search-services/config.ru'
daemonize true
bind "tcp://0.0.0.0:#{AppConfig[env][:port]}"
pidfile AppConfig[env][:pidfile]
threads 1, 1 # min, max
workers AppConfig[env][:num_workers]
environment env
# STDOUT, STDERR, append
stdout_redirect '/live/apps/dataset-search-services/run/logs/puma.stdout.log', '/live/apps/dataset-search-services/run/logs/puma.stderr.log', true
