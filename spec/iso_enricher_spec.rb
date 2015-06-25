require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/model/search/result_entry'
require_relative '../lib/nsidc_open_search/entry_enrichers/iso'

describe NsidcOpenSearch::EntryEnrichers::Iso do
  before :each do
    allow(RestClient).to receive(:get).and_return(iso_document_fixture)
    @result_entry = NsidcOpenSearch::Dataset::Model::Search::ResultEntry.new(id: '12345')
  end

  describe '#enrich_entry' do
    def described_method(entry)
      described_class.new('http://testurl.org/test').enrich_entry(entry)
    end

    it 'should set a data access' do
      described_method(@result_entry)
      expected_url = 'ftp://sidads.colorado.edu/pub/DATASETS/fgdc/ggd221_soiltemp_antarctica/'

      expect(@result_entry.data_access.length).to be 1
      expect(@result_entry.data_access[0].url).to eql expected_url
      expect(@result_entry.data_access[0].name).to eql 'Get Data'
      expect(@result_entry.data_access[0].description).to eql 'Data Access URL'
      expect(@result_entry.data_access[0].type).to eql 'download'
    end

    it 'should set supporting programs' do
      described_method(@result_entry)
      expect(@result_entry.supporting_programs.length).to be 2
      expect(@result_entry.supporting_programs[0]).to eql 'NSIDC_MEASURES'
      expect(@result_entry.supporting_programs[1]).to eql 'NSIDC_DAAC'
    end
  end
end
