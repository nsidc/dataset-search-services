# frozen_string_literal: true

require 'rsolr-ext'
require_relative 'search'
require_relative 'dataset/search/definitions/definition'
require_relative 'dataset/search/solr_search_facets'
require_relative 'dataset/search/parsers/solr_facets_parser'
require_relative 'dataset/model/facets/facets_response_builder'
require_relative 'dataset/search/factories/parameter_facets_factory'

module NsidcOpenSearch
  class DatasetFacets
    include Search

    search_definition NsidcOpenSearch::Dataset::Search::Definition
    param_factory NsidcOpenSearch::Dataset::Search::FacetsParameterFactory

    def initialize(url, query_config)
      self.class.send(
        :search,
        NsidcOpenSearch::Dataset::Search::SolrSearchFacets.new(
          url,
          NsidcOpenSearch::Dataset::Search::SolrFacetsParser,
          NsidcOpenSearch::Dataset::Model::Facets::FacetsResponseBuilder,
          query_config,
          RSolr::Ext
        )
      )
    end
  end
end
