# frozen_string_literal: true

require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(
  File.dirname(__FILE__),
  '..', 'lib', 'nsidc_open_search', 'dataset', 'search', 'definitions', 'definition'
)
require File.join(File.dirname(__FILE__), '..', 'lib', 'nsidc_open_search', 'validator')

describe NsidcOpenSearch::Validator do
  let(:obj) { Object.new }
  let(:definition) do
    class_double(
      NsidcOpenSearch::Dataset::Search::Definition, valids: [
        { required: [:searchterms], optional: [:bbox] },
        { required: [:searchterms], optional: [:loc] }
      ]
    )
  end

  before do
    obj = Object.new
    obj.class.send :include, described_class
    obj.class.send :search_definition, definition
  end

  describe 'is valid' do
    it 'is true when parameters contain a set of valid inputs' do
      obj.validate! searchterms: 'sea ice', loc: '10 20 30 40'
      expect(obj.valid?).to be true
    end

    it 'is true when parameters do not contain all optional inputs' do
      obj.validate! searchterms: 'sea ice'
      expect(obj.valid?).to be true
    end

    it 'is false when parameters do not contain a valid set of inputs' do
      obj.validate! loc: '10 20 30 40'
      expect(obj.valid?).to be false
    end
  end

  describe 'valid terms' do
    it 'contains a list of the DSL terms when parameters contain valid inputs' do
      obj.validate! searchterms: 'sea ice', bbox: '10 20 30 40'
      expect(obj.valid_terms).to eql %i[searchterms bbox]
    end

    it 'contains a list of the DSL terms when parameters contain only required inputs' do
      obj.validate! searchterms: 'sea ice'
      expect(obj.valid_terms).to eql [:searchterms]
    end

    it 'is empty when the parameters do not contain valid inputs' do
      obj.validate! bbox: '10 20 30 40'
      expect(obj.valid_terms).to be_empty
    end
  end
end
