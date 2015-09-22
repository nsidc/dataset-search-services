require 'bundler/setup'

Bundler.require(:default, :test)

# Require all support files
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

RSpec.configure do |c|
  c.filter_run_excluding disabled: true
end
