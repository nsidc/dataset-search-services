# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/factories/parameter_factory'

describe NsidcOpenSearch::Dataset::Search::ParameterFactory do
  let(:valids) { [:q] }

  it 'inserts default query parameters' do
    search_params = described_class.construct(
      {},
      valids
    )
    expect(search_params).to eql({})
  end

  it 'includes valid query parameters' do
    search_params = described_class.construct(
      { q: 'sea' },
      valids
    )
    expect(search_params).to eql q: 'sea'
  end

  it 'excludes empty query parameters' do
    search_params = described_class.construct(
      { q: '' },
      valids
    )
    expect(search_params).to eql({})
  end

  it 'excludes invalid query parameters' do
    search_params = described_class.construct(
      { q: 'sea', searchTerms: 'ice' },
      valids
    )
    expect(search_params).to eql q: 'sea'
  end
end
