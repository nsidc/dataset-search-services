require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'search', 'parsers', 'solr_suggestions_parser')
require File.join(File.dirname(__FILE__), 'helpers/solr_suggestion_response.rb')

describe NsidcOpenSearch::Dataset::Search::SolrSuggestionsParser do
  before :each do
    @config = YAML.load_file File.join(File.dirname(__FILE__), '..', 'config', 'solr_query_config_test.yml')
    @solr_response = solr_suggestion_response
    @suggestion_result = NsidcOpenSearch::Dataset::Search::SolrSuggestionsParser.new(response: @solr_response, services_config: @config['NSIDC'])
  end

  describe 'suggestion response' do
    it 'should return a suggestion' do
      @suggestion_result.entries[0].completion.should eql 'sea ice'
    end
  end
end
