require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'validator')

describe 'validator' do
  before :each do
    @definition = double('dsl definition', valids: [
      { required: [:searchterms], optional: [:bbox] },
      { required: [:searchterms], optional: [:loc] }
    ])

    @obj = Object.new
    @obj.class.send :include, NsidcOpenSearch::Validator
    @obj.class.send :search_definition, @definition
  end

  describe 'is valid' do
    it 'should be true when parameters contain a set of valid inputs' do
      @obj.validate! searchterms: 'sea ice', loc: '10 20 30 40'
      @obj.valid?.should be true
    end

    it 'should be true when parameters do not contain all optional inputs' do
      @obj.validate! searchterms: 'sea ice'
      @obj.valid?.should be true
    end

    it 'should be false when parameters do not contain a valid set of inputs' do
      @obj.validate! loc: '10 20 30 40'
      @obj.valid?.should be false
    end

  end

  describe 'valid terms' do
    it 'should contain a list of the DSL terms when parameters contain valid inputs' do
      @obj.validate! searchterms: 'sea ice', bbox: '10 20 30 40'
      @obj.valid_terms.should eql [:searchterms, :bbox]
    end

    it 'should contain a list of the DSL terms when parameters contain only required inputs' do
      @obj.validate! searchterms: 'sea ice'
      @obj.valid_terms.should eql [:searchterms]
    end

    it 'should be empty when the parameters do not contain valid inputs' do
      @obj.validate! bbox: '10 20 30 40'
      @obj.valid_terms.should be_empty
    end
  end
end
