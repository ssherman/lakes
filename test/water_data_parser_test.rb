require 'test_helper'

class WaterDataParserTest < Minitest::Test

  def test_water_data_on_texoma
    content = File.read('test/data/water_data/Texoma.txt')
    parser = Lakes::Texas::WaterDataParser.new(content)
    assert_equal 617.0, parser.conservation_pool_elevation_in_ft_msl
    assert_equal 95.0, parser.percentage_full
  end

  def test_water_data_on_abilene
    content = File.read('test/data/water_data/Abilene.txt')
    parser = Lakes::Texas::WaterDataParser.new(content)
    assert_equal 2012.3, parser.conservation_pool_elevation_in_ft_msl
    assert_equal 52.8, parser.percentage_full
  end
end
