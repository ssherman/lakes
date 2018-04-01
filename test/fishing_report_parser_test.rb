require 'test_helper'

class FishingReportParserTest < Minitest::Test
  def test_belton
    content = File.read('test/data/fishing_reports/belton.html')
    parser = Lakes::Texas::FishingReportParser.new(content)
    assert_equal 'Mar 28, 2018', parser.raw_date
    assert_equal 3, parser.date.month
    assert_equal 28, parser.date.day
    assert_equal 2018, parser.date.year
    assert_equal 'Water stained; 70–74 degrees; 2.42’ low. Black bass are good on topwaters and spinnerbaits in coves. Hybrid striper are good on live shad early. White bass are good on light blue jigs. Crappie are good on minnows in 30 feet. Channel and blue catfish are good on bloodbait, stinkbait, and minnows. Yellow catfish are good on trotlines and throwlines baited with perch.', parser.report
  end

  def test_palo_duro
    content = File.read('test/data/fishing_reports/palo_duro.html')
    parser = Lakes::Texas::FishingReportParser.new(content)
    assert_nil parser.raw_date
    assert_nil parser.date
    assert_nil parser.report 
  end

end
