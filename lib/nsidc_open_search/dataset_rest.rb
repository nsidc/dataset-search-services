# frozen_string_literal: true

require 'rsolr-ext'
require_relative 'search'
require_relative 'dataset/search/definitions/definition'
require_relative 'dataset/search/solr_search_rest'
require_relative 'dataset/search/factories/parameter_dataset_factory'
require_relative 'dataset/search/parsers/solr_results_parser'
require_relative 'dataset/model/dataset/dataset_response_builder'

module NsidcOpenSearch
  class DatasetRest
    include Search

    search_definition NsidcOpenSearch::Dataset::Search::Definition
    param_factory NsidcOpenSearch::Dataset::Search::DatasetParameterFactory

    def initialize(url, query_config)
      self.class.send(
        :search,
        NsidcOpenSearch::Dataset::Search::SolrSearchRest.new(
          url,
          NsidcOpenSearch::Dataset::Search::SolrResultsParser,
          NsidcOpenSearch::Dataset::Model::Dataset::DatasetResponseBuilder,
          query_config,
          RSolr::Ext
        )
      )
    end
  end
end
