# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'search_adapter')

# rubocop:disable RSpec/DescribeClass
describe 'search mapper' do
  let(:params) { { searchterms: 'sea ice', bbox: '10 20 30 40' } }
  let(:valids) { %i[searchterms bbox] }
  let(:search) { instance_double(NsidcOpenSearch::Dataset::Search::SolrSearchStandard) }
  let(:param_factory) { class_double(NsidcOpenSearch::Dataset::Search::ParameterFactory) }
  let(:results) do
    instance_double(
      NsidcOpenSearch::Dataset::Model::Dataset::DatasetResponseBuilder,
      total_results: 2, entries: []
    )
  end
  let(:obj) { Object.new }

  before do
    allow(search).to(receive(:execute).with(params).and_return(results))
    allow(param_factory).to receive(:construct).and_return(params)

    obj.class.send :include, NsidcOpenSearch::SearchAdapter
    obj.class.send :search, search
    obj.class.send :param_factory, param_factory
  end

  describe 'search' do
    it 'sets each term in list of valid terms' do
      obj.execute_search params, valids
      expect(param_factory).to have_received(:construct)
      expect(search).to have_received(:execute).with(params)
    end

    it 'returns a valid search result' do
      result = obj.execute_search params, valids
      expect(result.total_results).to be 2
    end
  end
end
# rubocop:enable RSpec/DescribeClass
