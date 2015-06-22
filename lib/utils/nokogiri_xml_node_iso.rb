module Nokogiri
  module XML
    class Node
      def iso_character_string
        res = at_xpath('gco:CharacterString')
        res.text.strip unless res.nil?
      end

      def iso_decimal
        at_xpath('gco:Decimal').text.strip.to_f
      end

      def iso_date
        return nil if children.empty?
        Date.parse(text.strip)
      end
    end
  end
end
