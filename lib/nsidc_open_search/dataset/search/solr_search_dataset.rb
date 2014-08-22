require File.join(File.dirname(__FILE__), 'solr_search_standard')

module NsidcOpenSearch
  module Dataset
    module Search
      class SolrSearchDataset < SolrSearchStandard
        private

        # override
        def build_solr_params(search_params, config)
          # SOLR has a 0 based index but OpenSearch has a 1 based index, so adjust for solr
          start = search_params[:startIndex].to_i - 1
          count = search_params[:count].to_i

          super(search_params, config).merge(
            'start' => (start if start > 0),
            'rows' => (count if count > 0),
            'sort' => build_sort_parameter(search_params)
          )
        end

        # Fields we support sorting on; keys are the fields as they appear in the OpenSearch feed,
        # the values are the corresponding fields that are stored in Solr. If the OpenSearch query
        # wants to sort on a field that is not a key here, it is simply ignored.
        OPENSEARCH_TO_SOLR_FIELDS = {
          'score' => 'score',
          'updated' => 'last_revision_date',
          'temporal_duration' => 'temporal_duration',
          'spatial_area' => 'spatial_area'
        }

        DEFAULT_SORT = 'score desc'

        def build_sort_parameter(search_params)
          return DEFAULT_SORT unless search_params.key?(:sortKeys)

          sort_keys = search_params[:sortKeys].split(' ')
          return DEFAULT_SORT if sort_keys.length == 0

          solr_sort_params = []
          sort_keys.each do |key|
            solr_sort = opensearch_sort_key_to_solr_sort_param(key)
            solr_sort_params.push(solr_sort) if solr_sort != ''
          end
          solr_sort_params.join(',')
        end

        # The OpenSearch extension which provides sortKeys has 1 required parameter and 4 optional
        # parameters.Our implementation allows queries formed with all parameters, but only acts on
        # the required parameter and the ascending parameter.
        #
        # For more info on the OpenSearch extension, see
        # http://docs.oasis-open.org/search-ws/searchRetrieve/v1.0/os/part3-sru2.0/searchRetrieve-v1.0-os-part3-sru2.0.html#_Toc324162458
        #
        # For moe info on sorting in Solr, see
        # http://wiki.apache.org/solr/CommonQueryParameters#sort
        def opensearch_sort_key_to_solr_sort_param(os_key)
          path, _sort_schema, ascending, _case_sensitive, _missing_value = os_key.split(',')
          field_name = OPENSEARCH_TO_SOLR_FIELDS[path]
          return '' if field_name.nil?

          # values that can be used in the opensearch to indicate to sort in
          # ascending order (descending is default)
          asc = %w(asc true 1)

          direction = asc.include?(ascending) ? 'asc' : 'desc'
          "#{field_name} #{direction}"
        end
      end
    end
  end
end
