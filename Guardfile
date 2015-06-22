guard 'rake', task: 'spec:unit' do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb}) { |m| "spec/#{m[1]}_spec.rb" }
end

guard :rubocop do
  watch(/.+\.(rb|rake)/)
  watch(/(Guard|Rake)file/)
  watch(%r{(?:.+/)?\.rubocop\.yml}) { |m| File.dirname(m[0]) }
end

guard('puma',
      bind: 'tcp://0.0.0.0:3000',
      threads: '1:1',
      workers: 5,
      environment: 'development',
      config: '-'
     ) do
  watch('Gemfile.lock')
  watch(%r{^config|lib/.*})
end
