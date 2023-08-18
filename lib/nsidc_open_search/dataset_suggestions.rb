# frozen_string_literal: true

require 'rsolr'
require_relative 'search'
require_relative 'dataset/search/definitions/definition_suggest'
require_relative 'dataset/search/solr_search_suggest'
require_relative 'dataset/search/parsers/solr_suggestions_parser'
require_relative 'dataset/model/suggestions/suggestions_response_builder'
require_relative 'dataset/search/factories/parameter_factory'

module NsidcOpenSearch
  class DatasetSuggestions
    include Search

    search_definition NsidcOpenSearch::Dataset::Search::DefinitionSuggest
    param_factory NsidcOpenSearch::Dataset::Search::ParameterFactory

    def initialize(url, query_config)
      self.class.send(
        :search,
        NsidcOpenSearch::Dataset::Search::SolrSearchSuggest.new(
          url,
          NsidcOpenSearch::Dataset::Search::SolrSuggestionsParser,
          NsidcOpenSearch::Dataset::Model::Suggestions::SuggestionsResponseBuilder,
          query_config,
          RSolr
        )
      )
    end
  end
end
