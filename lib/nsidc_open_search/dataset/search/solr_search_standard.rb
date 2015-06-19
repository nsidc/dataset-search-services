require_relative 'solr_search_base'

module NsidcOpenSearch
  module Dataset
    module Search
      class SolrSearchStandard < SolrSearchBase
        private

        # override
        def build_solr_params(search_params, config)
          {
            'q' => build_q_parameter(search_params),
            'fq' =>  build_fq_parameter(search_params),
            'qf' => build_qf_parameter(search_params, config),
            'pf' => build_pf_parameter(search_params, config),
            'ps' => config['phrase_slop'],
            'defType' => 'edismax',
            'bq' => config['boost_query'],
            'bf' => config['boost_function'],
            'boost' => config['boost']
          }
        end

        FIELD_QUERY_TERM_KEYS = [:spatial, :startDate, :endDate]
        GENERIC_QUERY_TERM_KEYS = [:searchTerms, :id, :q]
        OPERATOR = 'AND'

        def build_fields(fields, boosts)
          fields.map do |field|
            if boosts.key?(field.to_s)
              "#{field}^#{boosts[field.to_s]}"
            else
              field
            end
          end.join(' ')
        end

        def build_fq_parameter(search_params)
          filters = ["source:#{search_params[:source]}"]
          begin
            JSON.parse(search_params[:facetFilters]).each do |k, v|
              filters << "{!tag=#{k}}#{k}:#{get_facet_filter(v)}"
            end
          rescue
            filters
          end
          filters
        end

        def build_generic_terms(generic_terms)
          # Terms should be qualified with their field name unless this is the
          # all fields search term
          generic_terms.map do |k, v|
            if k.eql?(:searchTerms)
              format_query_term(v)
            else
              "#{k}:#{format_query_term(v)}"
            end
          end
        end

        def build_qf_parameter(search_params, config)
          qf = build_query_fields(search_params)
          qf = config['query_fields'] if qf.nil?

          build_fields(qf, config['query_field_boosts'])
        end

        def build_pf_parameter(search_params, config)
          pf = build_query_fields(search_params)
          pf = config['phrase_fields'] if pf.nil?

          build_fields(pf, config['phrase_field_boosts'])
        end

        def build_q_parameter(search_params)
          # If we have any query terms, group them together by field and join
          # them with the default operator. Strip quotes from phrase query
          # strings and remove any operators.  Operators are removed to simplify
          # parsing of the string and inserting operators.
          # TODO: Handle inserting operators while preseving existing operators
          # and strip quoted strings
          # NOTE: BWB (6/2014) - I think this may no longer be needed due to
          #       removing constrains drop down, not confident I know all edge
          #       cases. Also should address if we upgrade.

          # See http://lucene.apache.org/core/2_9_4/queryparsersyntax.html for
          # some search syntax help.  To explain of the structuring of the
          # query, consider the following searches:
          #
          # Find all datasets with 'sea ice', expect 206 results:
          # 'sea ice' in all fields => 206 results
          # '(sea ice)' in all fields => 206 results
          # '(sea AND ice)' in all fields => 206 results

          # Find all datasets with 'sea ice' in the titles, expect 55 results:
          # 'title:sea ice' in all fields => 64 results -- matches 'sea' in
          #    title and 'ice' in the rest of the document
          # 'title:(sea ice)' in all fields => 55 results
          # 'title:(sea AND ice)' in all fields => 55 results
          # 'sea ice' in title field => 55 results
          # 'title:(sea ice)' in title ield => 55 results
          # 'title:(sea AND ice)' in title ield => 55 results
          #
          # Find all datasets with 'Hydrographic' and with 'Ocean Circulation'
          # in the parameters, expect 2 results
          # 'parameters:Ocean Circulation Hydrographic' in all fields => 3
          #   results -- matches 'Ocean' in parameters and 'Circulation
          #   Hydrographic' in the rest of the document)
          # 'Hydrographic parameters:Ocean Circulation' in all fields => 3
          #   results -- matches 'Ocean' in parameters and 'Circulation
          #   Hydrographic' in the rest of the document)
          # 'Hydrographic parameters:(Ocean Circulation)' in all fields => 8
          #   results -- What??!! this got translated as Hydrographic AND
          #   parameters:(Ocean OR Circulation)
          # 'Hydrographic parameters:(Ocean AND Circulation)' in all fields => 2
          #   results

          # There appears to be a bug in SOLR's edismax parser with grouped
          # terms and the default operator. This also appears to occur when
          # using the mm parameter. The bug might be fixed in 4.4 (we're using
          # 4.3). For more info, see:
          # http://lucene.472066.n3.nabble.com/edismax-inconsistency-AND-OR-td2131795.html
          # http://stackoverflow.com/questions/7092767/solr-edismax-does-not-always-use-the-defaultoperator-and
          # https://issues.apache.org/jira/browse/SOLR-2649

          # Split up the search terms into values that have to go in the SOLR 'q' parameter.
          # Generic terms can be passed with or without specifying the field name.
          # Field terms must be passed with the field names
          generic_terms = get_terms(search_params, GENERIC_QUERY_TERM_KEYS)
          field_terms = get_terms(search_params, FIELD_QUERY_TERM_KEYS)

          if generic_terms.empty? && field_terms.empty?
            # If there aren't any terms, do a global search
            '*:*'
          elsif generic_terms.length.eql?(1) && field_terms.empty?
            # If there is only one generic term and no field terms, just
            # returned the formatted term
            format_query_term(generic_terms.values.first, false)
          else
            # Otherwise, build an operator separated list of the formatted terms
            operator_joined_terms(
              build_generic_terms(generic_terms) << build_spatial_term(field_terms) <<
                build_temporal_term(field_terms)
            )
          end
        end

        def build_query_fields(search_params)
          # Get the fields we are querying. Either the list of generic field
          # names or nil if we have to search all fields
          query_terms = get_terms(search_params, GENERIC_QUERY_TERM_KEYS)
          query_terms.keys.clone unless query_terms.empty? || query_terms.key?(:searchTerms)
        end

        def build_spatial_term(field_terms)
          return unless field_terms.key?(:spatial)

          # Expect a spatial search string with the format
          # westLon,southLat,eastLon,northLat this allows us to easily
          # construct a Lucene Spatial query with the format [southLat,westLon
          # TO northLat,eastLon]
          coords = field_terms[:spatial].split(',')
          fail 'Invalid spatial search. Input must have the format westLon,southLat,eastLon,'\
               'northLat' unless coords.length == 4
          "spatial:[#{coords[1]},#{coords[0]} TO #{coords[3]},#{coords[2]}]"
        end

        # Solr indexes temporal ranges as points in a spatial field.
        # - the start and end date will each have the format YY.YYMMDD
        # - the start date needs to be converted to a latitude
        # - the end date needs to be converted to a longitude
        #
        # - To find all datasets with ranges that intersect the start date and
        #   end date range, create a query with the format [start_date,0 TO
        #   90,end_date], which means search every thing with start and end
        #   dates within the given range.
        #
        # - To find all datasets with ranges that intersect the start date,
        #   create a query with the format [start_date,0 TO 90,180], which means
        #   search every thing with an end date after the given start date.
        #
        # - To find all datasets with ranges that intersect the end date, create
        #   a query with the format [0,0 TO 90,enddate], which means search every
        #   thing with a start date before the given end date.
        def build_temporal_term(field_terms)
          return if [:startDate, :endDate].none?(&field_terms.method(:key?))

          if field_terms.key?(:startDate)
            formatted_start = format_temporal_start(field_terms[:startDate])
          end

          if field_terms.key?(:endDate)
            formatted_end = format_temporal_end(field_terms[:endDate])
          end

          "temporal:[#{formatted_start || '0'},0 TO 90,#{formatted_end || '180'}]"
        end

        def build_terms(terms)
          terms.map do |k, v|
            if k.eql? :searchTerms
              format_query_term(v)
            else
              "#{k}:#{format_query_term(v)}"
            end
          end.reject(&:nil?).join(" #{OPERATOR} ")
        end

        def format_query_term(term, include_params = true)
          # remove quotes from phrases and split the keywords up
          unquoted = term.gsub(/"/, ' ').gsub('(', '\(').gsub(')', '\)')
          unquoted = unquoted.split(' ').select { |t| t.length >= 2 }
          unquoted = unquoted.reject { |t| %w(and or).include?(t.downcase) }

          str = %(#{(unquoted).join(" #{OPERATOR} ")})
          include_params ? "(#{str})" : str
        end

        def format_temporal(date_str, offset)
          # Solr dates in ranges are lat/longs and need to be formatted as
          # YY.YYMMDD. Convert theses to a float and include an offset to handle
          # points.
          (DateTime.parse(date_str).strftime('%C.%y%m%d').to_f + offset).round(7)
        end

        def format_temporal_end(date_str)
          # Solr spatial search has a hard time finding points, so search for a
          # date 1/10 of a day after the end date
          format_temporal date_str, 0.0000001
        end

        def format_temporal_start(date_str)
          # Solr spatial search has a hard time finding points, so search for a
          # date 1/10 of a day before the start date
          format_temporal date_str, -0.0000001
        end

        def get_facet_filter(values)
          # Normally :phrase_filter would work but turns out that internally
          # transform multiple values into a quoted string in different fq
          # :filters does not do that but we need to build the solr join query
          # manually, this method transform an ["val1", "va12"] into '("val1"
          # "va2")'
          # ref: https://github.com/mwmitchell/rsolr-ext/blob/master/lib/rsolr-ext/request.rb
          # ref: http://stackoverflow.com/questions/5296441/passing-comma-seperated-values-in-filter-query-of-solr-response
          %[("#{values.join('" "')}")]
        end

        def get_terms(search_params, key_list)
          search_params.select { |k, v| key_list.include?(k) && !v.nil_or_whitespace? }
        end

        def operator_joined_terms(terms_arr)
          terms_arr.reject(&:nil?).join(" #{OPERATOR} ")
        end
      end
    end
  end
end
