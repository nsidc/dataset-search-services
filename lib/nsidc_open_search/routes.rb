# frozen_string_literal: true

module NsidcOpenSearch
  module Routes
    def self.named(name)
      @named[name]
    end

    @named = {
      dataset_osdd: '/OpenSearchDescription',
      dataset_swagger_docs: '/SwaggerDocs',
      dataset_search: '/OpenSearch',
      dataset_facets: '/Facets',
      dataset_rest: '/id/*',
      dataset_suggestions: '/suggest'
    }
  end
end
