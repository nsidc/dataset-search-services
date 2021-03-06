require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/solr_search_suggest'

describe NsidcOpenSearch::Dataset::Search::SolrSearchSuggest do
  let(:base_search_parameters) { { queryType: 'suggestions' } }

  # Make this look like solr_suggestion in the parser
  let(:solr_response) do
    double('entries', entries: ['sea ice', 'sea ice concentration', 'seasonally frozen ground'])
  end

  let(:rsolr) { double('rsolr', get: solr_response) }
  let(:query_config) do
    YAML.load_file File.join(File.dirname(__FILE__), '..', 'config', 'solr_query_config_test.yml')
  end
  let(:solr_search) do
    described_class.new(
      'localhost:8983',
      NsidcOpenSearch::Dataset::Search::SolrSuggestionsParser,
      NsidcOpenSearch::Dataset::Model::Suggestions::SuggestionsResponseBuilder,
      query_config
    )
  end

  before :each do
    allow(RSolr).to receive(:connect).and_return(rsolr)
  end

  describe 'suggestion request' do
    def get_should_receive_expectations(expected)
      expect(rsolr).to receive(:get) do |*args|
        expected.each do |k, v|
          expect(args[0][k]).to eql v
        end

        solr_response
      end
    end
  end
end
