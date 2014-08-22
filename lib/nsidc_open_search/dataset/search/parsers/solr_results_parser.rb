require File.join(File.dirname(__FILE__), '..', '..', 'model', 'search', 'result_entry')
require File.join(File.dirname(__FILE__), '..', '..', 'model', 'search', 'date_range')
require File.join(File.dirname(__FILE__), '..', '..', 'model', 'search', 'parameter')

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
            NsidcOpenSearch::Dataset::Model::Search::ResultEntry.new(
              id: d['authoritative_id'],
              dataset_version: d['dataset_version'],
              title: d['title'],
              summary: d['summary'],
              keywords: d['keywords'],
              url: d['dataset_url'],
              data_access_urls: d['data_access_urls'],
              parameters: parse_parameters(d['full_parameters']),
              authors: d['authors'],
              data_centers: d['data_centers'],
              spatial_coverages: d['spatial_coverages'],
              temporal_coverages: parse_temporal_coverages(d['temporal_coverages']),
              distribution_formats: d['distribution_formats'],
              last_revision_date: parse_revision_date(d['last_revision_date']),
              temporal_duration: d['temporal_duration'],
              spatial_area: d['spatial_area']
            )
          end
        end

        def parse_date(str)
          Date.parse(str)
        rescue
          nil
        end

        def parse_temporal_coverages(coverages)
          if coverages.nil?
            []
          else
            mapped_coverages = coverages.map do |c|
              dates = c.split(',')

              start_date = parse_date(dates[0])
              end_date = parse_date(dates[1])

              NsidcOpenSearch::Dataset::Model::Search::DateRange.new(start_date: start_date, end_date: end_date)
            end

            mapped_coverages.sort do |x, y|
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
          end
        end

        def parse_revision_date(date)
          if date.nil? || date.empty?
            nil
          else
            Date.parse(date)
          end
        end

        def parse_parameters(parameters)
          # parameters always follow this pattern:
          # category is always the first element
          # name is always the last element
          # topic is the second element if there are more than 2 elements
          # term is the thrid element if there are more than 3 element
          # variable 1-3 are fourth, fifth, and sixth elements if present
          if parameters.nil?
            []
          else
            parameters.map do |p|
              elements = p.split ' > '
              parameter = NsidcOpenSearch::Dataset::Model::Search::Parameter.new(category: elements.first, name: elements.last)

              parameter.topic = elements[1] if elements.length >= 3
              parameter.term = elements[2] if elements.length >= 4
              if elements.length >= 5
                (3..(elements.length - 2)).each do |i|
                  parameter.send "variable_#{i - 2}=", elements[i]
                end
              end

              parameter
            end
          end
        end
      end
    end
  end
end
