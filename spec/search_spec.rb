require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'search')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'dataset', 'model', 'search', 'open_search_response_builder')

describe NsidcOpenSearch::Search do
  let(:params) { { searchterms: 'sea ice' } }
  let(:valids) { { required: [:searchterms], optional: [] } }
  let(:valid_terms) { [:searchterms] }
  let(:search) { double('search impl') }
  let(:param_factory) { double('param factory impl') }
  let(:definition)  { double('search definition') }
  let(:entry_enricher) { double('entry enricher', enrich_entry: nil) }
  let(:results) { double('results', total_results: 2, entries: [{}, {}]) }
  let(:obj) { Object.new }

  before :each do
    search.stub(:execute).with(params).and_return(results)
    param_factory.stub(:construct).and_return(params)
    definition.stub(:valids).and_return([valids])

    obj.class.send :include, NsidcOpenSearch::Search
    obj.class.send :search_definition, definition
    obj.class.send :search, search
    obj.class.send :param_factory, param_factory
    obj.class.send :entry_enrichers, [entry_enricher]

    obj.stub(:validate!).and_call_original
    obj.stub(:execute_search).and_call_original
    obj.stub(:enrich_result).and_call_original
  end

  it 'should validate input, search, and enrich results with valid data' do
    obj.exec params
    obj.should have_received(:validate!).with(params)
    obj.should have_received(:execute_search).with(params, valid_terms)
    obj.should have_received(:enrich_result).with(results)
  end

  it 'should return search results' do
    result = obj.exec params
    result.should be result
  end

  it 'should raise an error if the parameters are invalid' do
    obj.stub(:valid?).and_return(false)

    expect { obj.exec params }.to raise_error
  end
end
