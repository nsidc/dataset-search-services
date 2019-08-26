# frozen_string_literal: true

begin
  require 'rspec/core/rake_task'

  namespace :spec do
    RSpec::Core::RakeTask.new(:unit) do |t|
      t.rspec_opts = %w[-f progress -f JUnit -o results.xml]
    end

    RSpec::Core::RakeTask.new(:acceptance, :tag) do |t, args|
      t.rspec_opts = %w[--require ./spec/acceptance/custom_formatter
                        --require turnip_formatter
                        -f CustomFormatter
                        --no-fail-fast]
      t.rspec_opts << "-f RSpecTurnipFormatter -o #{results_file(args[:tag])}.html \
        -f JUnit -o #{results_file(args[:tag])}.xml"

      # Capture tag argument used to exclude/skip tests. Note! Only one tag will
      # be recognized.
      t.rspec_opts << "--tag #{args[:tag]}" if args[:tag]

      t.pattern = './spec/acceptance/**/*{.feature}'
    end
  end
rescue LoadError
  puts 'No RSpec available'
end

def results_file(tag)
  results_file_name = 'spec_results'
  return results_file_name if tag.nil? || tag.rstrip.empty?

  results_file_name + "_#{tag}"
end
