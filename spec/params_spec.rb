require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'search', 'factories', 'parameter_factory')

describe NsidcOpenSearch::Dataset::Search::ParameterFactory do
  before :each do
    @valids = [:q]
  end

  it 'should insert default query parameters' do
    search_params = NsidcOpenSearch::Dataset::Search::ParameterFactory.construct({}, @valids)
    search_params.should eql Hash.new # using literal {} fails the test
  end

  it 'should include valid query parameters' do
    search_params = NsidcOpenSearch::Dataset::Search::ParameterFactory.construct({ q: 'sea' }, @valids)
    search_params.should eql q: 'sea'
  end

  it 'should exclude empty query parameters' do
    search_params = NsidcOpenSearch::Dataset::Search::ParameterFactory.construct({ q: '' }, @valids)
    search_params.should eql Hash.new # using literal {} fails the test
  end

  it 'should exclude invalid query parameters' do
    search_params = NsidcOpenSearch::Dataset::Search::ParameterFactory.construct({ q: 'sea', searchTerms: 'ice' }, @valids)
    search_params.should eql q: 'sea'
  end
end
