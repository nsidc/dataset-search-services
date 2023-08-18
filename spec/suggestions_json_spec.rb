# frozen_string_literal: true

require 'json'
require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/model/suggestions/suggestions_response_builder'
require_relative '../lib/nsidc_open_search/dataset/model/suggestions/suggestion_entry'

describe NsidcOpenSearch::Dataset::Model::Suggestions::SuggestionsResponseBuilder do
  describe 'result to json' do
    let(:result) do
      described_class.new(
        query_string: 'sea',
        entries: [
          NsidcOpenSearch::Dataset::Model::Suggestions::SuggestionEntry.new(
            completion: 'sea ice',
            description: 'ice in the sea',
            url: '/suggest?q=sea%20ice'
          ),
          NsidcOpenSearch::Dataset::Model::Suggestions::SuggestionEntry.new(
            completion: 'sea ice concentration',
            description: 'concentration of ice in the sea',
            url: '/suggest?q=sea%20ice%20concentration'
          )
        ]
      )
    end

    it 'outputs a valid json format' do
      json = result.to_json
      expect(json).to eql [
        'sea',
        ['sea ice', 'sea ice concentration']
      ].to_json
    end
  end
end
