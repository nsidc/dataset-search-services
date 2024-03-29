#!/usr/bin/env puma
# frozen_string_literal: true

require_relative 'app_config'

# Puma configuration file. See https://github.com/puma/puma for more information
# and example config files.

env = ENV.fetch('RACK_ENV', nil).to_s || 'development'

rackup '/live/apps/dataset-search-services/webapps/dataset-search-services/config.ru'
daemonize true
bind "tcp://0.0.0.0:#{AppConfig[env][:port]}"
pidfile AppConfig[env][:pidfile]
threads 1, 1 # min, max
workers AppConfig[env][:num_workers]
environment env
# STDOUT, STDERR, append
stdout_redirect(
  '/live/apps/dataset-search-services/run/logs/puma.stdout.log',
  '/live/apps/dataset-search-services/run/logs/puma.stderr.log',
  true
)
