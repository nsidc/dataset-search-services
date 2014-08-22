require 'rsolr'
require File.join(File.dirname(__FILE__), 'search')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'definitions', 'definition_suggest')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'solr_search_suggest')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'parsers', 'solr_suggestions_parser')
require File.join(File.dirname(__FILE__), 'dataset', 'model', 'suggestions', 'suggestions_response_builder')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'factories', 'parameter_factory')

module NsidcOpenSearch
  class DatasetSuggestions
    include Search

    search_definition NsidcOpenSearch::Dataset::Search::DefinitionSuggest
    param_factory NsidcOpenSearch::Dataset::Search::ParameterFactory

    def initialize(url, query_config)
      self.class.send :search, NsidcOpenSearch::Dataset::Search::SolrSearchSuggest.new(url, NsidcOpenSearch::Dataset::Search::SolrSuggestionsParser, NsidcOpenSearch::Dataset::Model::Suggestions::SuggestionsResponseBuilder, query_config, RSolr)
    end
  end
end
