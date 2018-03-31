require 'nokogiri'
module Lakes
  class Texas
    class FishingReportParser
      include Lakes::Helper

      attr_reader :raw_text
      attr_reader :raw_date
      attr_reader :date
      attr_reader :report

      def initialize(text)
        @raw_text = text
        parse
      end

      def parse
        current_fishing_report_doc = Nokogiri::HTML(raw_text)
        current_fishing_report_dl = current_fishing_report_doc.at('div.row.report div.container dl')
        return if current_fishing_report_dl.nil?

        date_text = current_fishing_report_dl.at('dt span.title').try(:text)
        @raw_date = cleanup_data(date_text) unless date_text.nil?

        report_text = current_fishing_report_dl.xpath('dd').try(:text)
        @report = cleanup_data(report_text) unless report_text.nil?
      end
    end
  end
end
