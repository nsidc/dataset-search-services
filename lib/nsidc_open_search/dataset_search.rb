require 'rsolr-ext'
require_relative 'search'
require_relative 'dataset/search/definitions/definition'
require_relative 'dataset/search/solr_search_dataset'
require_relative 'dataset/search/factories/parameter_results_factory'
require_relative 'dataset/search/parsers/solr_results_parser'
require_relative 'dataset/model/search/open_search_response_builder'

module NsidcOpenSearch
  class DatasetSearch
    include Search

    search_definition NsidcOpenSearch::Dataset::Search::Definition
    param_factory NsidcOpenSearch::Dataset::Search::ResultsParameterFactory

    def initialize(url, query_config)
      self.class.send(
        :search,
        NsidcOpenSearch::Dataset::Search::SolrSearchDataset.new(
          url,
          NsidcOpenSearch::Dataset::Search::SolrResultsParser,
          NsidcOpenSearch::Dataset::Model::Search::OpenSearchResponseBuilder,
          query_config,
          RSolr::Ext
        )
      )
    end
  end
end
