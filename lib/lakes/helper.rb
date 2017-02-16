module Lakes
  module Helper

    # texas lake pages are encoded in Windows-1252 :(
    def http_get(url)
      uri = URI(url)
      Net::HTTP.get(uri).encode('UTF-8', 'Windows-1252')
    end

    # texas lake websites use lots of non breaking spaces
    def cleanup_data(value)
      nbsp = 160.chr('UTF-8')
      value = value.strip.gsub(nbsp, '')
      value.empty? ? nil : value
    end

    def cleanup_raw_text(raw_text)
      raw_text.try(:gsub, /\s+/, ' ').try(:strip)
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
  end
end
