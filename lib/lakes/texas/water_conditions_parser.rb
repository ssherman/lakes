require 'nokogiri'
module Lakes
  class Texas
    class WaterConditionsParser
      include Lakes::Helper

      attr_reader :raw_text, :raw_text_without_whitespace
      attr_reader :water_data_uri
      attr_reader :conservation_pool_elevation_raw_text, :conservation_pool_elevation
      attr_reader :conservation_pool_elevation_in_ft_msl
      attr_reader :fluctuation_raw_text, :fluctuation
      attr_reader :normal_clarity_raw_text, :normal_clarity

      def initialize(text)
        return if text.nil?
        @raw_text = text
        @raw_text_without_whitespace = text.gsub(/[\t\r\n\f]+/, '').gsub(/\s\s/, ' ')
        parse
      end

      # <a href="http://waterdatafortexas.org/reservoirs/individual/belton">Current Lake Level</a>
      # Conservation Pool Elevation: 594 ft. msl
      # Fluctuation: 3-5 feet
      # Normal Clarity: Moderate
      def parse
        html_doc = Nokogiri::HTML.fragment(@raw_text)

        html_doc_without_whitespace_chars = Nokogiri::HTML.fragment(raw_text_without_whitespace)
        water_data_link = html_doc_without_whitespace_chars.xpath('p/a[contains(text(), "Current Lake Level")]').first
        @water_data_uri = water_data_link.try(:[], 'href')
        if @water_data_uri && @water_data_uri.start_with?('http://')
          @water_data_uri.gsub!('http://', 'https://')
        end

        text_doc = html_doc.text
        text_doc_without_whitespace = html_doc_without_whitespace_chars.text

        # so many inconsistencies in the data
        @conservation_pool_elevation_raw_text = text_doc
          .match(/(Conservation Pool Elevation:(.*))|(Normal water level:(.*))/i)
          .try(:captures)
          .try(:compact)
          .try(:[], 1)

        @conservation_pool_elevation = cleanup_raw_text(
          @conservation_pool_elevation_raw_text
        )

        @fluctuation_raw_text = text_doc.match(/Fluctuation: (.*)Normal Clarity:/im).try(:captures).try(:first)
        @fluctuation = cleanup_raw_text(@fluctuation_raw_text)

        @normal_clarity_raw_text = text_doc_without_whitespace.match(/Normal Clarity: (.*)/i).try(:captures).try(:first)
        @normal_clarity = cleanup_raw_text(@normal_clarity_raw_text)
      end
    end
  end
end
