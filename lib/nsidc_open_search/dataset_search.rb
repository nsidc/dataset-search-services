require 'rsolr-ext'
require File.join(File.dirname(__FILE__), 'search')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'definitions', 'definition')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'solr_search_dataset')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'factories', 'parameter_results_factory')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'parsers', 'solr_results_parser')
require File.join(File.dirname(__FILE__), 'dataset', 'model', 'search', 'open_search_response_builder')
require File.join(File.dirname(__FILE__), 'entry_enrichers', 'iso')

module NsidcOpenSearch
  class DatasetSearch
    include Search

    search_definition NsidcOpenSearch::Dataset::Search::Definition
    param_factory NsidcOpenSearch::Dataset::Search::ResultsParameterFactory

    def initialize(url, iso_service_url, enricher_thread_count, query_config)
      self.class.send :search, NsidcOpenSearch::Dataset::Search::SolrSearchDataset.new(url, NsidcOpenSearch::Dataset::Search::SolrResultsParser, NsidcOpenSearch::Dataset::Model::Search::OpenSearchResponseBuilder, query_config, RSolr::Ext)
      self.class.send :entry_enrichers, [NsidcOpenSearch::EntryEnrichers::Iso.new(iso_service_url)]
      self.class.send :enricher_thread_count, enricher_thread_count
    end
  end
end
