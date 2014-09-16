guard 'rake', task: 'spec:unit' do
  watch(/^spec\/.+_spec\.rb/)
  watch(/^lib\/(.+)\.rb/) { |m| "spec/#{m[1]}_spec.rb" }
end

guard :rubocop, cli: '--config .rubocop_project.yml' do
  watch(/.+\.(rb|rake)$/)
  watch(/(Guard|Rake|Gem)file$/)
  watch(/\.rubocop_.*\.yml$/) { |m| File.dirname(m[0]) }
end

guard 'puma', bind: 'tcp://0.0.0.0:3000', threads: '1:1', workers: 5, environment: 'development', config: '-' do
  watch('Gemfile.lock')
  watch(/^config|lib\/.*/)
end
