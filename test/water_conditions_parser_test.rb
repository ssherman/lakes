require 'test_helper'

class WaterConditionsParserTest < Minitest::Test

  def test_water_conditions_on_texoma
    content = File.read('test/data/water_conditions/Texoma.txt')
    parser = Lakes::Texas::WaterConditionsParser.new(content)
    assert_equal 'https://waterdatafortexas.org/reservoirs/individual/texoma', parser.water_data_uri
    assert_equal '615 to 619 ft. msl', parser.conservation_pool_elevation
    assert_equal '5-8 feet annually', parser.fluctuation
    assert_equal 'Moderate to clear', parser.normal_clarity
  end

  def test_water_conditions_on_decker
    content = File.read('test/data/water_conditions/Decker.txt')
    parser = Lakes::Texas::WaterConditionsParser.new(content)
    assert_equal nil, parser.water_data_uri
    assert_equal '555 ft. msl', parser.conservation_pool_elevation
    assert_equal 'Nearly constant level', parser.fluctuation
    assert_equal 'Clear to slightly stained', parser.normal_clarity
  end

  def test_water_conditions_on_alvarado_park
    content = File.read('test/data/water_conditions/Alvarado Park.txt')
    parser = Lakes::Texas::WaterConditionsParser.new(content)
    assert_equal nil, parser.water_data_uri
    assert_equal nil, parser.conservation_pool_elevation
    assert_equal '1-2 feet', parser.fluctuation
    assert_equal 'Stained to murky', parser.normal_clarity
  end

  def test_water_conditions_lake_falcon
    content = File.read('test/data/water_conditions/Falcon.txt')
    parser = Lakes::Texas::WaterConditionsParser.new(content)
    assert_equal 'https://waterdatafortexas.org/reservoirs/individual/falcon', parser.water_data_uri
    assert_equal '301.2 ft. msl', parser.conservation_pool_elevation
    assert_equal 'Severe, 40 to 50 feet or more', parser.fluctuation
    assert_equal 'Turbid (upper) to stained (lower)', parser.normal_clarity
  end

  def test_water_conditions_lake_diversion
    content = File.read('test/data/water_conditions/Diversion.txt')
    parser = Lakes::Texas::WaterConditionsParser.new(content)
    assert_equal nil, parser.water_data_uri
    assert_equal nil, parser.conservation_pool_elevation
    assert_equal nil, parser.fluctuation
    assert_equal nil, parser.normal_clarity
  end

  def test_water_conditions_nil
    content = nil
    parser = Lakes::Texas::WaterConditionsParser.new(content)
    assert_equal nil, parser.water_data_uri
    assert_equal nil, parser.conservation_pool_elevation
    assert_equal nil, parser.fluctuation
    assert_equal nil, parser.normal_clarity
  end
end
