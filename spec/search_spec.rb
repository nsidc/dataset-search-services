require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/search'
require_relative '../lib/nsidc_open_search/dataset/model/search/open_search_response_builder'

describe NsidcOpenSearch::Search do
  let(:params) { { searchterms: 'sea ice' } }
  let(:valids) { { required: [:searchterms], optional: [] } }
  let(:valid_terms) { [:searchterms] }
  let(:search) { double('search impl') }
  let(:param_factory) { double('param factory impl') }
  let(:definition)  { double('search definition') }
  let(:results) { double('results', total_results: 2, entries: [{}, {}]) }
  let(:obj) { Object.new }

  before :each do
    allow(search).to receive(:execute).with(params).and_return(results)
    allow(param_factory).to receive(:construct).and_return(params)
    allow(definition).to receive(:valids).and_return([valids])

    obj.class.send :include, NsidcOpenSearch::Search
    obj.class.send :search_definition, definition
    obj.class.send :search, search
    obj.class.send :param_factory, param_factory

    allow(obj).to receive(:validate!).and_call_original
    allow(obj).to receive(:execute_search).and_call_original
  end

  it 'should validate input and search' do
    obj.exec params
    expect(obj).to have_received(:validate!).with(params)
    expect(obj).to have_received(:execute_search).with(params, valid_terms)
  end

  it 'should return search results' do
    result = obj.exec params
    expect(result).to be result
  end

  it 'should raise an error if the parameters are invalid' do
    allow(obj).to receive(:valid?).and_return(false)

    expect { obj.exec(params) }.to raise_error(ArgumentError)
  end
end
