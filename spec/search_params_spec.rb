# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/factories/parameter_results_factory'

describe NsidcOpenSearch::Dataset::Search::ResultsParameterFactory do
  let(:expected) do
    {
      source: 'NSIDC',
      count: '25',
      startIndex: '1'
    }
  end
  let(:valids) { %i[searchTerms authors] }

  it 'inserts defaults search values' do
    search_params = described_class.construct(
      {},
      valids
    )
    expect(search_params).to eql expected
  end

  it 'excludes empty query parameters' do
    search_params = described_class.construct(
      { searchTerms: 'sea ice', authors: '' },
      valids
    )
    expect(search_params).to eql expected.merge(searchTerms: 'sea ice')
  end

  it 'excludes invalid query parameters' do
    search_params = described_class.construct(
      { searchTerms: 'sea ice', temp: '' },
      valids
    )
    expect(search_params).to eql expected.merge(searchTerms: 'sea ice')
  end
end
