require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Mobgpsd" do
  include Mobgpsd

  it "should create a nice nmea string" do
    NMEA.new(45.123, -32.456, 100, Time.at(28298392), 1, 8).to_s.
      should eql("$GPGGA,093952,450722.80,N,322721.60,W,1,8,0.9,100.0,M,0,M,,*75")
  end

end

# $GPGGA,181944.000,4835.3098,N,00911.4415,E,1,6,1.4,0471.0,M,0.0,M,,0000*69\r\n")
