require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'enricher')

describe 'enricher' do
  describe 'enrich result' do
    before :each do
      @result = double('result', entries: [{}])

      @obj = Object.new
      @obj.class.send :include, NsidcOpenSearch::Enricher
    end

    it 'should call enrich entry for each entry' do
      entry_enricher = double('entry enricher', enrich_entry: nil)
      @obj.class.send :entry_enrichers, [entry_enricher]

      @obj.enrich_result @result
      expect(entry_enricher).to have_received(:enrich_entry).exactly(@result.entries.length).times

      @obj.class.send :remove_method, :enrichers
    end

    it 'should handle empty entry enrichers list' do
      @obj.enrich_result @result
      expect(@result.entries).to eql [{}]
    end
  end
end
