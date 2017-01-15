require 'test_helper'

class LakesTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Lakes::VERSION
  end

  def test_basic_lake_characteristics
    content = File.read('test/data/lake_characteristics/Lady Bird Lake.txt')
    parser = LakeCharacteristicsParser.new(content)
    assert_equal 'On the Colorado River in downtown Austin', parser.location_desc
    assert_equal " 468 acres\r", parser.surface_area_raw_text
    assert_equal 468, parser.surface_area_in_acres
    assert_equal " 18 feet\r", parser.max_depth_raw_text
    assert_equal 18, parser.max_depth_in_feet
    assert_equal ' 1960', parser.year_impounded_raw_text
    assert_equal 1960, parser.year_impounded
  end

  def test_lake_conroe
    content = File.read('test/data/lake_characteristics/Conroe.txt')
    parser = LakeCharacteristicsParser.new(content)
    assert_equal 'West Fork of San Jacinto River in Montgomery and Walker Counties', parser.location_desc
    assert_equal " 20,118 acres\r", parser.surface_area_raw_text
    assert_equal 20118, parser.surface_area_in_acres
    assert_equal nil, parser.max_depth_raw_text
    assert_equal nil, parser.max_depth_in_feet
    assert_equal ' 1973', parser.year_impounded_raw_text
    assert_equal 1973, parser.year_impounded
  end

  def test_lake_fryer
    content = File.read('test/data/lake_characteristics/Fryer.txt')
    parser = LakeCharacteristicsParser.new(content)
    assert_equal 'Located in Wolf Creek Park in Ochiltree County, approximately 12 miles south of Perryton', parser.location_desc
    assert_equal " 86 acres\r", parser.surface_area_raw_text
    assert_equal 86, parser.surface_area_in_acres
    assert_equal " Average 13 feet, maximum 25 feet \r", parser.max_depth_raw_text
    assert_equal 25, parser.max_depth_in_feet
    assert_equal ' 1939, dam rebuilt in 1953', parser.year_impounded_raw_text
    assert_equal 1939, parser.year_impounded
  end

  def test_caddo_lake
    content = File.read('test/data/lake_characteristics/Caddo.txt')
    parser = LakeCharacteristicsParser.new(content)
    assert_equal 'On Big Cypress Bayou on the Texas-Louisiana state line, northeast of Marshall in Harrison and Marion counties', parser.location_desc
    assert_equal " 26,800 acres\r", parser.surface_area_raw_text
    assert_equal 26800, parser.surface_area_in_acres
    assert_equal " 20 feet\r", parser.max_depth_raw_text
    assert_equal 20, parser.max_depth_in_feet
    assert_equal " First dam built in 1914, \r\n  replaced in 1971", parser.year_impounded_raw_text
    assert_equal 1914, parser.year_impounded
  end
end
