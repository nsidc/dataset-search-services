require File.join(File.dirname(__FILE__), 'solr_search_base')

module NsidcOpenSearch
  module Dataset
    module Search
      class SolrSearchRest < SolrSearchBase
        # override
        def build_solr_params(search_params, _config)
          # get a list of fields to query
          {
            :queries => { authoritative_id: "#{search_params[:id]}" },
            'rows' => '1',
            'start' => '0'
          }
        end
      end
    end
  end
end
