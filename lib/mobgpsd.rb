require "mobgpsd/nmea"
require "mobgpsd/gpsd"
require "mobgpsd/web"

module Mobgpsd

  def self.start!
    @@gpsd ||= GPSD.new
  end

  def self.gpsd
    @@gpsd
  end

  def self.test!(data="$GPGGA,181944.000,4835.3098,N,00911.4415,E,1,6,1.4,0471.0,M,0.0,M,,0000*69\r\n")
    loop do
      @@gpsd << data
      sleep 0.033
    end
  end

end
