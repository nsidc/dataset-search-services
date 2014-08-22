require 'rsolr-ext'
require File.join(File.dirname(__FILE__), 'search')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'definitions', 'definition')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'solr_search_facets')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'parsers', 'solr_facets_parser')
require File.join(File.dirname(__FILE__), 'dataset', 'model', 'facets', 'facets_response_builder')
require File.join(File.dirname(__FILE__), 'dataset', 'search', 'factories', 'parameter_facets_factory')

module NsidcOpenSearch
  class DatasetFacets
    include Search

    search_definition NsidcOpenSearch::Dataset::Search::Definition
    param_factory NsidcOpenSearch::Dataset::Search::FacetsParameterFactory

    def initialize(url, query_config)
      self.class.send :search, NsidcOpenSearch::Dataset::Search::SolrSearchFacets.new(url, NsidcOpenSearch::Dataset::Search::SolrFacetsParser, NsidcOpenSearch::Dataset::Model::Facets::FacetsResponseBuilder, query_config, RSolr::Ext)
    end
  end
end
