require 'test_helper'
require 'mocha/minitest'

class ShareALunkerTest < Minitest::Test
  def test_share_parsing
    content = File.read('test/data/share_a_lunker.html')

    lunker = Lakes::Texas::ShareALunker.new
    lunker.expects(:http_get).with(Lakes::Texas::ShareALunker::URL).returns(content)

    assert_equal 570, lunker.list.count
    lunker.list.each do |l|
      assert !l[:id].nil?
      assert !l[:angler].nil?
      assert !l[:date_caught].nil?
    end
  end
end
