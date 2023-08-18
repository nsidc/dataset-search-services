# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'enricher')

describe NsidcOpenSearch::Enricher do
  describe 'enrich result' do
    let(:result) do
      instance_double(
        NsidcOpenSearch::Dataset::Model::Search::OpenSearchResponseBuilder,
        entries: [{}]
      )
    end
    let(:obj) { Object.new }

    before do
      obj.class.send :include, described_class
    end

    it 'calls enrich entry for each entry' do
      entry_enricher = instance_double(NsidcOpenSearch::EntryEnrichers::Dummy, enrich_entry: nil)
      obj.class.send :entry_enrichers, [entry_enricher]

      obj.enrich_result result
      expect(entry_enricher).to have_received(:enrich_entry).exactly(result.entries.length).times

      obj.class.send :remove_method, :enrichers
    end

    it 'handles empty entry enrichers list' do
      obj.enrich_result result
      expect(result.entries).to eql [{}]
    end
  end
end
