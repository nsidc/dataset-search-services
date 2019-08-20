# frozen_string_literal: true
begin
  require 'rspec/core/rake_task'
rescue LoadError
  puts "No RSpec available"
end

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.rspec_opts = %w[-f progress -f JUnit -o results.xml]
  end

  RSpec::Core::RakeTask.new(:acceptance, :tag) do |t, args|
    # capture any arguments
    t.rspec_opts = %w[-f progress -f RSpecTurnipFormatter -o results.html -f JUnit -o results.xml]
    t.rspec_opts << "--tag #{args[:tag]}" if args[:tag]
    t.pattern = './spec/acceptance/**/*{.feature}'
  end
end
