# frozen_string_literal: true

namespace :guard do
  desc 'Automatically run RuboCop'
  task :rubocop do
    sh 'bundle exec guard --plugin rubocop --no-interactions'
  end

  desc 'Automatically run unit tests'
  task :specs do
    sh 'bundle exec guard --plugin rake --no-interactions'
  end

  desc 'Automatically restart the puma server'
  task :puma do
    sh 'bundle exec guard --plugin puma --no-interactions'
  end
end

desc 'Activate guards for rubocop and the specs'
task :guard do
  sh 'bundle exec guard --plugin rake rubocop --no-interactions'
end
