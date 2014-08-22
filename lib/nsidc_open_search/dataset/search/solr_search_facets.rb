require File.join(File.dirname(__FILE__), 'solr_search_standard')

module NsidcOpenSearch
  module Dataset
    module Search
      class SolrSearchFacets < SolrSearchStandard
        private

        # override
        def build_solr_params(search_params, config)
          super(search_params, config).merge(
            'start' => '0',
            'rows' => '0',
            'facet' => 'true',
            'facet.field' => get_facet_fields(config)
          ).merge(get_configurable_parameters(config))
        end

        def get_configurable_parameters(config)
          configurable_parameters = {}.merge(get_facet_override_parameters(config['facets'])) unless config['facets'].nil?
          configurable_parameters.merge!(get_default_facet_parameters(config['facet_defaults']))
        end

        def get_default_facet_parameters(config)
          defaults = {}
          config.each_pair { |key, value| defaults[key] = value }
          defaults
        end

        def get_facet_fields(config)
          facets = []
          config['facets'].each do |f|
            facets << "{!ex=#{f['name']}}#{f['name']}"
          end
          facets
        end

        def get_facet_override_parameters(facet_config)
          override_params = {}
          facet_config.each do |f|
            f['solr'].each do |solr_key, solr_val|
              override_params["f.#{f['name']}.facet.#{solr_key}"] = solr_val
            end unless f['solr'].nil?
          end
          override_params
        end
      end
    end
  end
end
