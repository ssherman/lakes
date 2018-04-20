require 'test_helper'
require 'mocha/minitest'

class ShareLunkerTest < Minitest::Test
  def test_share_parsing
    content = File.read('test/data/share_lunker.html')

    lunker = Lakes::Texas::ShareLunker.new
    lunker.expects(:http_get).with(Lakes::Texas::ShareLunker::URL).returns(content)

    assert_equal 570, lunker.list.count
    lunker.list.each do |l|
      assert !l[:id].nil?
      assert !l[:angler].nil?
      assert !l[:date_caught].nil?
    end
  end
end
