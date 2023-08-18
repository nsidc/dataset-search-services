# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/factories/parameter_dataset_factory'

describe NsidcOpenSearch::Dataset::Search::DatasetParameterFactory do
  let(:expected) { { source: 'NSIDC', count: '0', startIndex: '1' } }
  let(:valids) { [] }

  it 'inserts defaults search values' do
    search_params = described_class.construct(
      {},
      valids
    )
    expect(search_params).to eql expected
  end

  it 'excludes empty query parameters' do
    search_params = described_class.construct(
      { splat: ['http://something.com'] },
      valids
    )
    expect(search_params).to eql expected.merge(id: '"http://something.com"')
  end

  it 'excludes invalid query parameters' do
    search_params = described_class.construct(
      { searchTerms: 'sea ice', splat: ['id-01'] },
      valids
    )
    expect(search_params).to eql expected.merge(id: '"id-01"')
  end
end
