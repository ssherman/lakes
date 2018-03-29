require 'nokogiri'
module Lakes
  class Texas
    class WaterDataParser
      include Lakes::Helper

      attr_reader :raw_text
      attr_reader :conservation_pool_elevation_in_ft_msl
      attr_reader :percentage_full

      def initialize(text)
        @raw_text = text
        # File.write("test/data/water_data/Abilene.txt", @raw_text)
        # puts "WaterDataParser: raw_text: #{@raw_text}"
        parse
      end

      def parse
        html_doc = Nokogiri::HTML(@raw_text)
        cons_pool_elevation_header_element = html_doc.xpath('//td[contains(text(), "Conservation pool elevation")]').first
        cons_pool_elevation_root = cons_pool_elevation_header_element.try(:next_element)
        @conservation_pool_elevation_in_ft_msl = cleanup_raw_text(cons_pool_elevation_root.try(:text))
          .try(:match, /([0-9,\.]+)/)
          .try(:captures)
          .try(:first)
          .try(:gsub, ',', '')
          .try(:to_f)

        percentage_full_element = cleanup_raw_text(html_doc.css('div.page-title h2 small').try(:text))
        @percentage_full = percentage_full_element
          .try(:match, /^([0-9]+\.?[0-9]+)/)
          .try(:captures)
          .try(:first)
          .try(:to_f)
      end
    end
  end
end
