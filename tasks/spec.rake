# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'

  namespace :spec do
    RSpec::Core::RakeTask.new(:unit) do |t|
      t.rspec_opts = %w[-f progress -f JUnit -o results.xml]
    end

    RSpec::Core::RakeTask.new(:acceptance, :tag) do |t, args|
      t.rspec_opts = %w[--require ./spec/acceptance/custom_formatter
                        -f CustomFormatter
                        -f RSpecTurnipFormatter -o results.html
                        -f JUnit -o results.xml
                        --no-fail-fast]

      # capture tag argument(s) used to exclude/skip tests
      t.rspec_opts << "--tag #{args[:tag]}" if args[:tag]
      t.pattern = './spec/acceptance/**/*{.feature}'
    end
  end
rescue LoadError
  puts 'No RSpec available'
end
