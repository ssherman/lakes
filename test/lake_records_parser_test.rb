require 'test_helper'

class LakeRecordsParserTest < Minitest::Test

  def test_rod_and_reel
    content = File.read('test/data/lake_records/belton.html')
    parser = Lakes::Texas::LakeRecordsParser.new(content)
    assert true, parser.records.keys.include?('Weight Records')
    assert true, parser.records.keys.include?('Catch and Release Records (by length)')
    assert true, parser.records['Weight Records'].keys.include?('All-Ages')
    assert true, parser.records['Weight Records'].keys.include?('Junior Angler')
  end

end
