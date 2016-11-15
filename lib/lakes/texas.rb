require 'net/http'
require 'nokogiri'
require 'date'
require 'try'

module Lakes
  class Texas
    attr_reader :lake_data

    def initialize
      @lake_data = {}
    end

    def list
      return @lake_data.keys unless @lake_data.empty?

      base_url = 'http://tpwd.texas.gov/fishboat/fish/recreational/lakes/'
      content = http_get("#{base_url}lakelist.phtml")
      html_doc = Nokogiri::HTML(content)
      
      # remove elements not needed to make parsing easier
      html_doc.search('div.announce, div.alert, div#bottomwrapper').each do |src|
        src.remove
      end

      html_doc.search('div#maincontent ul li a').each do |lake_html|
        lake_name = cleanup_data(lake_html.text)
        @lake_data[lake_name] = { details_uri: "#{base_url}#{lake_html[:href]}" }
      end
      @lake_data.keys
    end

    def get_details(lake_name)
      list
      data = lake_data[lake_name]
      raise 'Lake not found' if data.nil?

      parse_lake_details(data)
    end

    protected

    def parse_lake_details(lake_data)
      content = http_get(lake_data[:details_uri] + '/')
      html_doc = Nokogiri::HTML(content)
      main_div = html_doc.at('div#maincontent')

      parse_lake_characteristics(main_div, lake_data)
      parse_water_conditions(main_div, lake_data)
      parse_reservoir_controlling_authority(main_div, lake_data)
      parse_aquatic_vegetation(main_div, lake_data)
      parse_predominant_fish_species(main_div, lake_data)
      parse_lake_records(main_div, lake_data)
      parse_current_fishing_report(main_div, lake_data)
      parse_stocking_history(main_div, lake_data)
      parse_lake_surveys(main_div, lake_data)
      parse_lake_maps(main_div, lake_data)
      parse_fishing_regulations(main_div, lake_data)
      parse_angling_opportunities(main_div, lake_data)
      parse_fishing_structure(main_div, lake_data)
      parse_tips_and_tactics(main_div, lake_data)
      lake_data
    end

    def parse_tips_and_tactics(main_div, lake_data)
      data = main_div.xpath('//h6[contains(text(), "Tips & Tactics")]').first
      content = data.try(:next_element).try(:text)
      lake_data[:tips_and_tactics] = content
    end

    def parse_fishing_structure(main_div, lake_data)
      data = main_div.xpath('//h6[contains(text(), "Fishing Cover/Structure")]').first
      content = data.try(:next_element).try(:to_html)
      lake_data[:structure_and_cover_description] = content
    end

    def parse_angling_opportunities(main_div, lake_data)
      data = main_div.xpath('//h6[contains(text(), "Angling Opportunities")]').first
      description = data.try(:next_element).try(:text)
      lake_data[:angling_opportunities_description] = description

      table = main_div.css('#Ratings')
      quality = ['Poor', 'Fair', 'Good', 'Excellent']

      fish_species_elements = table.css('tr th.highlight2')
      lake_data[:angling_opportunities_details] = {}
      fish_species_elements.each do |fish_species_element|
        rating_index = 0
        species = cleanup_data(fish_species_element.text)
        while fish_species_element = fish_species_element.next_element
          if fish_species_element.css('img').count == 0
            rating_index += 1
            next
          else
            lake_data[:angling_opportunities_details][species] = quality[rating_index]
            break
          end
        end
      end
    end

    def parse_fishing_regulations(main_div, lake_data)
      process_simple_section(main_div, lake_data, 'Fishing Regulations', :fishing_regulations, true)
    end

    def parse_lake_maps(main_div, lake_data)
      process_simple_section(main_div, lake_data, 'Lake Maps', :lake_maps, false)
    end

    def parse_lake_characteristics(main_div, lake_data)
      process_simple_section(main_div, lake_data, 'Lake Characteristics', :lake_characteristics, false)
    end

    def parse_water_conditions(main_div, lake_data)
      process_simple_section(main_div, lake_data, 'Water Conditions', :water_conditions, true)
    end

    def parse_reservoir_controlling_authority(main_div, lake_data)
      process_simple_section(main_div, lake_data, 'Reservoir Controlling Authority', :reservoir_controlling_authority, false)
    end

    def parse_aquatic_vegetation(main_div, lake_data)
      process_simple_section(main_div, lake_data, 'Aquatic Vegetation', :aquatic_vegetation, false)
    end

    def parse_predominant_fish_species(main_div, lake_data)
      element = main_div.xpath('//h6[contains(text(), "Predominant Fish Species")]').first
      species_root = element.try(:next_element)
      species = species_root.nil? ? nil : species_root.css('li').map{ |e| cleanup_data(e.text) }
      lake_data[:predominant_fish_species] = species
    end

    def parse_lake_surveys(main_div, lake_data)
      link = main_div.xpath('p/a[contains(text(), "Latest Survey Report")]').first
      stocking_history = if link.nil?
        nil
      else
        uri = link['href']
        lake_data[:latest_survey_report] = convert_relative_href(uri, lake_data[:details_uri])
      end
    end

    def parse_stocking_history(main_div, lake_data)
      link = main_div.xpath('p/a[contains(text(), "Stocking History")]').first
      stocking_history = if link.nil?
        nil
      else
        uri = link['href']
        lake_data[:stocking_history_uri] = convert_relative_href(uri, lake_data[:details_uri])

        content = http_get(lake_data[:stocking_history_uri])
        stocking_history_doc = Nokogiri::HTML(content)

        stocking_history_table = stocking_history_doc.at('div#maincontent table')
        headers = stocking_history_table.xpath('tr/th').map{ |r| r.text }
        rows = stocking_history_table.xpath('tr/td').map{ |r| r.text }

        table_data = process_data_table(headers, rows)
        lake_data[:stocking_history] = table_data
      end
    end

    def parse_current_fishing_report(main_div, lake_data)
      link = main_div.xpath('p/a[contains(text(), "Fishing Report")]').first
      fishing_report = if link.nil?
        nil
      else
        uri = link['href']
        lake_data[:current_fishing_report_uri] = convert_relative_href(uri, lake_data[:details_uri])

        content = http_get(lake_data[:current_fishing_report_uri])
        current_fishing_report_doc = Nokogiri::HTML(content)
        current_fishing_report_dl = current_fishing_report_doc.at('div.row.report div.container dl')

        date = cleanup_data(current_fishing_report_dl.at('dt span.title').text)
        report = cleanup_data(current_fishing_report_dl.xpath('dd').text)
        {date: date, report: report}
      end

      lake_data[:current_fishing_report] = fishing_report
    end

    def parse_lake_records(main_div, lake_data)
      link = main_div.xpath('//a[contains(text(), "Lake Records")]').first
      if link.nil?
        lake_data[:fishing_records_uri] = nil
        return
      end
      uri = link['href']
      lake_data[:fishing_records_uri] = convert_relative_href(uri, lake_data[:details_uri])

      content = http_get(lake_data[:fishing_records_uri])
      lake_records_doc = Nokogiri::HTML(content)
      lake_records_main_div = lake_records_doc.at('div#maincontent')

      # H2's are record types like:
      # - weight records
      # - catch and release records (by length)

      element = lake_records_main_div.children.first
      current_record_type = nil # Weight or Length
      current_age_group = nil # all ages, youth, etc
      fishing_records_data = {}
      while element = element.next_element
        case element.name
        when 'h2'
          current_record_type = cleanup_data(element.text)
          fishing_records_data[current_record_type] = {}
        when 'h3'
          current_age_group = cleanup_data(element.text)
          fishing_records_data[current_record_type][current_age_group] = {}
        when 'table'
          fishing_method = cleanup_data(element.xpath('caption/big').text)

          if fishing_records_data[current_record_type][current_age_group][fishing_method].nil?
            fishing_records_data[current_record_type][current_age_group][fishing_method] = []
          end

          headers = element.xpath('tr/th').map{ |r| r.text }
          rows = element.xpath('tr/td').map{ |r| r.text }

          table_data = process_data_table(headers, rows)
          fishing_records_data[current_record_type][current_age_group][fishing_method] = table_data
        end
      end
      lake_data[:fishing_records] = fishing_records_data
    end

    # converts a html table with headers and rows into
    # an array of hashes with header => value
    def process_data_table(headers, rows)
      data = []
      header_count = headers.length
      row_count = rows.count / header_count

      row_data_index = 0
      row_count.times do |row_index|

        entry = {}
        header_count.times do |header_index|
          header = cleanup_data(headers[header_index])
          table_data = cleanup_data(rows[row_data_index])
          row_data_index += 1
          entry[header] = table_data
        end
        data << entry
      end
      data
    end

    # converts this:
    # ../../../action/waterecords.php?WB_code=0001
    # into this:
    # http://tpwd.texas.gov/fishboat/fish/action/waterecords.php?WB_code=0001
    # based on this:
    # http://tpwd.texas.gov/fishboat/fish/recreational/lakes/abilene
    def convert_relative_href(href, current_url)
      relative_depth = href.split('..').count - 1
      url_parts = current_url.split('/')
      url_parts.slice!(-relative_depth, relative_depth)
      fixed_href = href.gsub('../', '')
      url_parts.join('/') + '/' + fixed_href
    end

    # texas lake websites use lots of non breaking spaces
    def cleanup_data(value)
      nbsp = 160.chr('UTF-8')
      value = value.strip.gsub(nbsp, '')
      value.empty? ? nil : value
    end

    def process_simple_section(main_div, lake_data, section_title, data_name, html)
      data = main_div.xpath("//h6[contains(text(), \"#{section_title}\")]").first
      element_type_function = html ? :to_html : :text
      content = data.try(:next_element).try(element_type_function)
      lake_data[data_name] = content
    end

    # texas lake pages are encoded in Windows-1252 :(
    def http_get(url)
      uri = URI(url)
      Net::HTTP.get(uri).encode('UTF-8', 'Windows-1252')
    end
  end
end