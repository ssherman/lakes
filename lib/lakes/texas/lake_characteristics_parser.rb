class LakeCharacteristicsParser
  attr_reader :raw_text, :location_desc
  attr_reader :surface_area_raw_text, :surface_area_in_acres
  attr_reader :max_depth_raw_text, :max_depth_in_feet
  attr_reader :year_impounded_raw_text, :year_impounded

  def initialize(text)
    @raw_text = text
    #puts "text: #{@raw_text}"
    #File.write("test/data/lake_characteristics/Conroe.txt", @raw_text)
    parse
  end

  def parse
    @location_desc = @raw_text.match(/^location:(.*)(surface area)|(surface acres)|(maximum depth|impounded):/im).captures.first
    @surface_area_raw_text = @raw_text.match(/surface (area|acres):(.*)/i).try(:captures).try(:[], 1)
    @max_depth_raw_text = @raw_text.match(/maximum depth:(.*)/i).try(:captures).try(:first)
    @year_impounded_raw_text = @raw_text.match(/impounded:(.*)/i).try(:captures).try(:first)

    @location_desc = cleanup_raw_text(@location_desc)

    @surface_area_in_acres = cleanup_raw_text(@surface_area_raw_text)
      .try(:match, /^([0-9,]+)/)
      .try(:captures)
      .try(:first)
      .try(:delete, ',')
      .try(:to_i)

    @max_depth_in_feet = cleanup_raw_text(@max_depth_raw_text)
      .try(:match, /^([0-9,]+)/)
      .try(:captures)
      .try(:first)
      .try(:delete, ',')
      .try(:to_i)

    # need to handle bad data like Lake Fryer which is:
    # Maximum depth: Average 13 feet, maximum 25 feet
    if @max_depth_in_feet.nil?
      @max_depth_in_feet = cleanup_raw_text(@max_depth_raw_text)
        .try(:match, /maximum ([0-9,]+) feet/i)
        .try(:captures)
        .try(:first)
        .try(:delete, ',')
        .try(:to_i)
    end

    @year_impounded = cleanup_raw_text(@year_impounded_raw_text)
      .try(:match, /^([0-9,]+)/)
      .try(:captures)
      .try(:first)
      .try(:delete, ',')
      .try(:to_i)

  end

  def cleanup_raw_text(raw_text)
    raw_text.try(:gsub, /\s+/, ' ').try(:strip)
  end
end
