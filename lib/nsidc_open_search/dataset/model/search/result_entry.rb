# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'utils', 'auto_initializer')

module NsidcOpenSearch
  module Dataset
    module Model
      module Search
        class ResultEntry < AutoInitializer
          attr_accessor :id, :dataset_version, :title, :summary, :parameters,
                        :keywords, :url, :data_access_urls,
                        :authors, :data_centers, :supporting_programs,
                        :spatial_coverages, :temporal_coverages,
                        :distribution_formats, :last_revision_date,
                        :temporal_duration, :spatial_area

          def initialize(args)
            @parameters = []
            @keywords = []
            @data_access_urls = []
            @authors = []
            @data_centers = []
            @supporting_programs = []
            @spatial_coverages = []
            @temporal_coverages = []
            @distribution_formats = []

            super args
          end
        end
      end
    end
  end
end
