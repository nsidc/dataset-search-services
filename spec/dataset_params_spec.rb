require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/search/factories/parameter_dataset_factory'

describe NsidcOpenSearch::Dataset::Search::DatasetParameterFactory do
  before :each do
    @expected = {
      source: 'NSIDC',
      count: '0',
      startIndex: '1'
    }

    @valids = []
  end

  it 'should insert defaults search values' do
    search_params = NsidcOpenSearch::Dataset::Search::DatasetParameterFactory.construct(
      {},
      @valids
    )
    expect(search_params).to eql @expected
  end

  it 'should exclude empty query parameters' do
    search_params = NsidcOpenSearch::Dataset::Search::DatasetParameterFactory.construct(
      { splat: ['http://something.com']  },
      @valids
    )
    expect(search_params).to eql @expected.merge(id: "\"http://something.com\"")
  end

  it 'should exclude invalid query parameters' do
    search_params = NsidcOpenSearch::Dataset::Search::DatasetParameterFactory.construct(
      { searchTerms: 'sea ice', splat: ['id-01'] },
      @valids
    )
    expect(search_params).to eql @expected.merge(id: "\"id-01\"")
  end
end
