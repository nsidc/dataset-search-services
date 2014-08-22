require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'search_adapter')

describe 'search mapper' do
  let(:params) { { searchterms: 'sea ice', bbox: '10 20 30 40' } }
  let(:valids) { [:searchterms, :bbox] }
  let(:search) { double('search impl') }
  let(:param_factory) { double('param factory impl') }
  let(:obj) { Object.new }

  before :each do
    search.stub(:execute).with(params).and_return(double('results', total_results: 2, entries: []))
    param_factory.stub(:construct).and_return(params)

    obj.class.send :include, NsidcOpenSearch::SearchAdapter
    obj.class.send :search, search
    obj.class.send :param_factory, param_factory
  end

  describe 'search' do
    it 'should set each term in list of valid terms' do
      obj.execute_search params, valids
      param_factory.should have_received(:construct)
      search.should have_received(:execute).with(params)
    end

    it 'should return a valid search result' do
      result = obj.execute_search params, valids
      result.total_results.should be 2
    end
  end
end
