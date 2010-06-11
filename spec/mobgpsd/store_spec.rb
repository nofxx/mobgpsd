require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
include Mobgpsd

N1 = NMEA.new(45.123, -32.456, 100, Time.at(28298392), 1, 8)
N2 = NMEA.new(-45.123, 35.456, 567.8, Time.at(27898392), 1, 9)

describe "Mobgpsd::Store" do

  before do
    @store = Mobgpsd::Store.new
    @store.drop
  end

  it "should store a fix" do
    @store << { "geom" =>  [12.34, 56.78], "hour" => 100, "z" => 0 }
    @store.count.should eql(1)
  end

  it "should store an array fix" do
    @store << [12.34, 56.78, 100, 0]
    @store.count.should eql(1)
  end

end

# $GPRMC,083144.34,V,2111.532629,S,4658.980979,W,,,100610,,,N*71
