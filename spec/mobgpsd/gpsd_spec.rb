require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Mobgpsd

N1 = NMEA.new(45.123, -32.456, 100, Time.at(28298392), 1, 8)
N2 = NMEA.new(-45.123, 35.456, 567.8, Time.at(27898392), 1, 9)

describe "Mobgpsd::GPSD" do

  it "should send a NMEA packet" do
    pending
    c = GPSD.new
    c.send N2.to_s
    c.close
  end

end

# $GPRMC,083144.34,V,2111.532629,S,4658.980979,W,,,100610,,,N*71
