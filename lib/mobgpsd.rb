require "mobgpsd/nmea"
require "mobgpsd/gpsd"
require "mobgpsd/web"

module Mobgpsd

  class << self
  attr_reader :gpsd, :store

  def start!
    if STORE
      puts "[MobGPSD] Starting store..."
      require "mobgpsd/store"
      @store = Store.new
    end
    @gpsd  = GPSD.new
  end

  def test!(data="TEST")
    loop do
      @gpsd << data
      sleep 1 #0.033 # 33ms
    end
  end

  end
end
