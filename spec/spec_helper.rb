require 'bundler/setup'

ENV['RACK_ENV'] = 'test'

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

  # Approach suggested by https://github.com/rspec/rspec-core/issues/1793
  if ENV['LIST_TAGS']
    def tags_in(groups)
      tags = groups.flat_map do |g|
        g.metadata.keys + tags_in(g.children)
      end.uniq - RSpec::Core::Metadata::RESERVED_KEYS
      tags.select { |tag| tag =~ /search_|osdd_/ }
    end

    c.before(:suite) do
      tags = tags_in(RSpec.world.example_groups)
      puts "Tags:"
      puts tags.join("\n")
      exit(0)
    end
  end
end
