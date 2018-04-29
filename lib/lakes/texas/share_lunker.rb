require 'nokogiri'
module Lakes
  class Texas
    class ShareLunker
      include Lakes::Helper
      URL = 'https://tpwd.texas.gov/spdest/visitorcenters/tffc/sharelunker/archives/lunkersearch_adv.phtml'

      WEEKDAYS = {
        'mon' => 'Monday',
        'tue' => 'Tuesday',
        'wed' => 'Wednesday',
        'thu' => 'Thursday',
        'fri' => 'Friday',
        'sat' => 'Saturday',
        'sun' => 'Sunday'
      }

      def initialize
        @lunker_data = []
      end

      def list
        return @lunker_data unless @lunker_data.empty?
        content = http_get(URL)
        html_doc = Nokogiri::HTML(content)

        results = []
        html_doc.search('div#contentwide table tr').each_with_index do |row, index|
          next if index == 0
          data = row.search('th, td')

          girth = cleanup_raw_text(data[6].text)
          girth = girth.nil? ? nil : girth.to_f

          length = cleanup_raw_text(data[5].text)
          length = length.nil? ? nil : length.to_f

          status = cleanup_raw_text(data[15].text)
          died = status.try(:downcase)
          died = if !died.nil? 
            died.match('died').try(:length) == 1
          end

          results << {
            id: data[0].text.to_i,
            details_uri: convert_relative_href("../" + data[0].search('a')[0][:href], URL),
            date_caught: Date.strptime(cleanup_raw_text(data[1].text), '%m/%d/%Y'),
            angler: cleanup_raw_text(data[2].text),
            angler_location: cleanup_raw_text(data[3].text),
            weight: cleanup_raw_text(data[4].text).to_f,
            length: length,
            girth: girth,
            type: cleanup_raw_text(data[7].text),
            lake: cleanup_raw_text(data[8].text),
            record: cleanup_raw_text(data[9].text),
            caught_on: cleanup_raw_text(data[10].text),
            day_of_week: WEEKDAYS[cleanup_raw_text(data[11].text).try(:downcase)],
            moon_phase: cleanup_raw_text(data[12].text),
            spawned: convert_YN_boolean(cleanup_raw_text(data[13].text)),
            returned_to_lake: convert_YN_boolean(cleanup_raw_text(data[14].text)),
            status: cleanup_raw_text(data[15].text),
            died: died
          }
        end
        @lunker_data = results
        return @lunker_data
      end

      private
      def convert_YN_boolean(value)
        v = value.try(:downcase)
        v = if v == 'Y'
          true
        elsif v == 'N'
          false
        else
          nil
        end
        v
      end

    end
  end
end
