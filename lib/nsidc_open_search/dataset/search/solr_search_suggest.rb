require File.join(File.dirname(__FILE__), '..', '..', '..', 'utils', 'class_extensions')

module NsidcOpenSearch
  module Dataset
    module Search
      class SolrSearchSuggest < SolrSearchStandard
        # override
        def build_solr_params(search_params, config)
          {
            'defType' => 'edismax',
            'q' => build_q_parameter(search_params),
            'fq' => (search_params[:source].nil? ? '' : "source:#{search_params[:source]}"),
            'qf' => 'text_suggest_edge^50 text_suggest_infix^40 text_suggest_ngram',
            'boost' => 'product(weight,query({!type=edismax qf=$qf pf=$pf ps=$ps bq=$bq v=$q boost=}))'
          }
        end

        # override
        def get_response_builder_params(response, search_params)
          {
            entries: response.entries,
            query_string: search_params[:q]
          }
        end

        # override
        def query_solr(solr_params)
          @solr.get('select', params: solr_params)
        end
      end
    end
  end
end
