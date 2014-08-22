require 'rsolr-ext'
require File.join(File.dirname(__FILE__), 'search')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'definitions', 'definition')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'solr_search_rest')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'factories', 'parameter_dataset_factory')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'parsers', 'solr_results_parser')
require File.join(File.dirname(__FILE__), 'dataset', 'model', 'dataset', 'dataset_response_builder')

module NsidcOpenSearch
  class DatasetRest
    include Search

    search_definition NsidcOpenSearch::Dataset::Search::Definition
    param_factory NsidcOpenSearch::Dataset::Search::DatasetParameterFactory

    def initialize(url, query_config)
      self.class.send :search, NsidcOpenSearch::Dataset::Search::SolrSearchRest.new(url, NsidcOpenSearch::Dataset::Search::SolrResultsParser, NsidcOpenSearch::Dataset::Model::Dataset::DatasetResponseBuilder, query_config, RSolr::Ext)
    end
  end
end
