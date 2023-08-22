# frozen_string_literal: true

require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/search'
require_relative '../lib/nsidc_open_search/dataset/model/search/open_search_response_builder'
require_relative '../lib/nsidc_open_search/dataset/search/definitions/definition'
require_relative '../lib/nsidc_open_search/dataset/search/factories/parameter_factory'
require_relative '../lib/nsidc_open_search/entry_enrichers/dummy'

describe NsidcOpenSearch::Search do
  let(:params) { { searchterms: 'sea ice' } }
  let(:valids) { { required: [:searchterms], optional: [] } }
  let(:valid_terms) { [:searchterms] }
  let(:search) { instance_double(NsidcOpenSearch::Dataset::Search::SolrSearchStandard) }
  let(:param_factory) { class_double(NsidcOpenSearch::Dataset::Search::ParameterFactory) }
  let(:definition) { class_double(NsidcOpenSearch::Dataset::Search::Definition) }
  let(:entry_enricher) do
    instance_double(NsidcOpenSearch::EntryEnrichers::Dummy, enrich_entry: nil)
  end
  let(:results) do
    instance_double(
      NsidcOpenSearch::Dataset::Model::Dataset::DatasetResponseBuilder,
      total_results: 2, entries: [{}, {}]
    )
  end
  let(:obj) { Object.new }

  before do
    allow(search).to receive(:execute).with(params).and_return(results)
    allow(param_factory).to receive(:construct).and_return(params)
    allow(definition).to receive(:valids).and_return([valids])

    obj.class.send :include, described_class
    obj.class.send :search_definition, definition
    obj.class.send :search, search
    obj.class.send :param_factory, param_factory
    obj.class.send :entry_enrichers, [entry_enricher]

    allow(obj).to receive(:validate!).and_call_original
    allow(obj).to receive(:execute_search).and_call_original
    allow(obj).to receive(:enrich_result).and_call_original
  end

  it 'validates input, search, and enrich results with valid data' do
    obj.exec params
    expect(obj).to have_received(:validate!).with(params)
    expect(obj).to have_received(:execute_search).with(params, valid_terms)
    expect(obj).to have_received(:enrich_result).with(results)
  end

  it 'returns search results' do
    result = obj.exec params
    expect(result).to be results
  end

  it 'raises an error if the parameters are invalid' do
    allow(obj).to receive(:valid?).and_return(false)

    expect { obj.exec(params) }.to raise_error(ArgumentError)
  end
end
