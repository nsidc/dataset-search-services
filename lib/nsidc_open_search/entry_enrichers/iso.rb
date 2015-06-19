require 'date'
require 'nokogiri'
require 'rest_client'
require_relative '../dataset/model/search/data_access'
require_relative '../../utils/nokogiri_xml_node_iso'

module NsidcOpenSearch
  module EntryEnrichers
    class Iso
      def initialize(iso_url)
        @iso_url = iso_url
      end

      def enrich_entry(entry)
        iso_document = RestClient.get "#{@iso_url}/#{entry.id}" rescue nil

        if iso_document.nil?
          # log.info('Result entry cannot be enriched without an iso document')
          return
        end

        doc = Nokogiri::XML iso_document.sub(
          /<gmi:MI_Metadata version="1.0">/,
          '<gmi:MI_Metadata xmlns:gco="http://www.isotc211.org/2005/gco" '\
          'xmlns:gmd="http://www.isotc211.org/2005/gmd" '\
          'xmlns:gml="http://www.opengis.net/gml/3.2" '\
          'xmlns:gts="http://www.isotc211.org/2005/gts" '\
          'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '\
          'xmlns:gmi="http://www.isotc211.org/2005/gmi" version="1.0">')

        entry.data_access = data_access doc
        entry.supporting_programs = supporting_programs doc
      end

      private

      def data_access(doc)
        doc.xpath('//gmd:MD_DigitalTransferOptions/gmd:onLine').map do |e|
          NsidcOpenSearch::Dataset::Model::Search::DataAccess.new(
            url: e.at_xpath('.//gmd:URL').text.strip,
            name: e.at_xpath('.//gmd:name').iso_character_string,
            description: e.at_xpath('.//gmd:description').iso_character_string,
            type: e.at_xpath('.//gmd:CI_OnlineResource//gmd:CI_OnLineFunctionCode').text.strip
          )
        end
      end

      def supporting_programs(doc)
        path = '//gmd:MD_DataIdentification/'\
               'gmd:pointOfContact/'\
               'gmd:CI_ResponsibleParty[.//gmd:CI_RoleCode="custodian"]/'\
               'gmd:organisationShortName'

        doc.xpath(path).map(&:iso_character_string)
      end
    end
  end
end
