require_relative 'spec_helper'
require_relative '../lib/nsidc_open_search/dataset/model/search/result_entry'
require_relative '../lib/nsidc_open_search/entry_enrichers/iso'

describe NsidcOpenSearch::EntryEnrichers::Iso do
  before :each do
    RestClient.stub(:get).and_return(iso_document_fixture)
    @result_entry = NsidcOpenSearch::Dataset::Model::Search::ResultEntry.new(id: '12345')
  end

  describe '#enrich_entry' do
    def described_method(entry)
      described_class.new('http://testurl.org/test').enrich_entry(entry)
    end

    it 'should set a data access' do
      described_method(@result_entry)
      expected_url = 'ftp://sidads.colorado.edu/pub/DATASETS/fgdc/ggd221_soiltemp_antarctica/'

      @result_entry.data_access.length.should be 1
      @result_entry.data_access[0].url.should eql expected_url
      @result_entry.data_access[0].name.should eql 'Get Data'
      @result_entry.data_access[0].description.should eql 'Data Access URL'
      @result_entry.data_access[0].type.should eql 'download'
    end

    it 'should set supporting programs' do
      described_method(@result_entry)
      @result_entry.supporting_programs.length.should be 2
      @result_entry.supporting_programs[0].should eql 'NSIDC_MEASURES'
      @result_entry.supporting_programs[1].should eql 'NSIDC_DAAC'
    end
  end
end
