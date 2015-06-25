namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.rspec_opts = %w(-f progress -f JUnit -o results.xml)
  end

  RSpec::Core::RakeTask.new(:acceptance) do |t|
    t.rspec_opts = %w(-f progress -f RSpecTurnipFormatter -o results.html -f JUnit -o results.xml)
    t.pattern = './spec/acceptance/**/*{.feature}'
  end
end
