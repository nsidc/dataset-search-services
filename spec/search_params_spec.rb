require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'search', 'factories', 'parameter_results_factory')

describe NsidcOpenSearch::Dataset::Search::ResultsParameterFactory do
  before :each do
    @expected = {
      source: 'NSIDC',
      count: '25',
      startIndex: '1'
    }

    @valids = [:searchTerms, :authors]
  end

  it 'should insert defaults search values' do
    search_params = NsidcOpenSearch::Dataset::Search::ResultsParameterFactory.construct({}, @valids)
    expect(search_params).to eql @expected
  end

  it 'should exclude empty query parameters' do
    search_params = NsidcOpenSearch::Dataset::Search::ResultsParameterFactory.construct({ searchTerms: 'sea ice', authors: '' }, @valids)
    expect(search_params).to eql @expected.merge(searchTerms: 'sea ice')
  end

  it 'should exclude invalid query parameters' do
    search_params = NsidcOpenSearch::Dataset::Search::ResultsParameterFactory.construct({ searchTerms: 'sea ice', temp: '' }, @valids)
    expect(search_params).to eql @expected.merge(searchTerms: 'sea ice')
  end
end
