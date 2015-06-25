require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/parsers/solr_suggestions_parser'
require_relative 'helpers/solr_suggestion_response.rb'

describe NsidcOpenSearch::Dataset::Search::SolrSuggestionsParser do
  before :each do
    @config = YAML.load_file(File.expand_path('../../config/solr_query_config_test.yml', __FILE__))
    @solr_response = solr_suggestion_response
    @suggestion_result = NsidcOpenSearch::Dataset::Search::SolrSuggestionsParser.new(
      response: @solr_response,
      services_config: @config['NSIDC']
    )
  end

  describe 'suggestion response' do
    it 'should return a suggestion' do
      expect(@suggestion_result.entries[0].completion).to eql 'sea ice'
    end
  end
end
