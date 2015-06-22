require_relative '../../model/search/result_entry'
require_relative '../../model/search/date_range'
require_relative '../../model/search/parameter'

module NsidcOpenSearch
  module Dataset
    module Search
      class SolrResultsParser
        attr_reader :total_results, :entries

        def initialize(options)
          response = options[:response]['response']
          @total_results = response['numFound']
          @entries = parse_docs response['docs']
        end

        private

        def parse_docs(docs)
          docs.map do |d|
            entry = {
              id: d['authoritative_id'],
              last_revision_date: parse_revision_date(d['last_revision_date']),
              parameters: parse_parameters(d['full_parameters']),
              temporal_coverages: parse_temporal_coverages(d['temporal_coverages']),
              url: d['dataset_url']
            }

            %w(authors data_access_urls data_centers dataset_version distribution_formats
               keywords spatial_area spatial_coverages summary temporal_duration
               title).each do |key|
              entry[key.to_sym] = d[key]
            end

            NsidcOpenSearch::Dataset::Model::Search::ResultEntry.new(entry)
          end
        end

        def parse_date(str)
          Date.parse(str)
        rescue
          nil
        end

        def sort_temporal_coverages(x, y)
          if x.start_date == y.start_date

            # nil end_date means a continous data set, treat those as if
            # their end dates are after all other end dates
            if x.end_date.nil?
              1
            elsif y.end_date.nil?
              -1
            else
              x.end_date <=> y.end_date
            end

          else
            x.start_date <=> y.start_date
          end
        end

        def parse_temporal_coverages(coverages)
          return [] if coverages.nil?

          coverages.map do |coverage|
            start_date, end_date = coverage.split(',').map(&method(:parse_date))

            NsidcOpenSearch::Dataset::Model::Search::DateRange.new(
              start_date: start_date,
              end_date: end_date
            )
          end.sort(&method(:sort_temporal_coverages))
        end

        def parse_revision_date(date)
          if date.nil? || date.empty?
            nil
          else
            Date.parse(date)
          end
        end

        # parameters always follow this pattern:
        # - category is always the first element
        # - name is always the last element
        # - topic is the second element if there are more than 2 elements
        # - term is the third element if there are more than 3 element
        # - variable 1-3 are fourth, fifth, and sixth elements if present
        def parse_parameters(parameters)
          parameters.to_a.map do |parameter|
            attrs = {}

            attrs[:category], *optional, attrs[:name] = parameter.split(' > ')

            attrs[:topic], attrs[:term], *variables = optional

            attrs[:variable_1], attrs[:variable_2], attrs[:variable_3] = variables

            NsidcOpenSearch::Dataset::Model::Search::Parameter.new(attrs)
          end
        end
      end
    end
  end
end
