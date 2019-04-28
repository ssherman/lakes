require 'nokogiri'
module Lakes
  class Texas
    class LakeRecordsParser
      include Lakes::Helper

      attr_reader :raw_text
      attr_reader :records

      def initialize(text)
        @raw_text = text
        @records = {}
        parse
      end

      def parse
        lake_records_doc = Nokogiri::HTML(@raw_text)
        lake_records_main_div = lake_records_doc.at('div#maincontent')

        # H2's are record types like:
        # - weight records
        # - catch and release records (by length)

        element = lake_records_main_div.children.first
        current_record_type = nil # Weight or Length
        current_age_group = nil # all ages, youth, etc
        while element = element.next_element
          case element.name
          when 'h2'
            current_record_type = cleanup_data(element.text)
            @records[current_record_type] = {}
          when 'h3'
            current_age_group = cleanup_data(element.text)
            @records[current_record_type][current_age_group] = {}
          when 'table'
            fishing_method = cleanup_data(element.xpath('caption/big').text)

            if @records[current_record_type][current_age_group][fishing_method].nil?
              @records[current_record_type][current_age_group][fishing_method] = []
            end

            headers = element.xpath('tr/th').map{ |r| r.text }
            rows = element.xpath('tr/td').map{ |r| r.text }

            table_data = process_data_table(headers, rows)
            @records[current_record_type][current_age_group][fishing_method] = table_data
          end
        end

      end
    end
  end
end
