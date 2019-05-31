require 'bundler/setup'

Bundler.require(:default, :test)

# Require all support files
Dir[File.dirname(__FILE__) + '/support/**/*.rb'].each { |f| require f }

def iso_document_fixture
  File.open(File.expand_path('../fixtures/iso_document.xml', __FILE__), 'rb') do |iso_doc_file|
    begin
      iso_doc_file.read
    ensure
      iso_doc_file.close
    end
  end
end

RSpec.configure do |c|
  c.filter_run_excluding disabled: true
end
