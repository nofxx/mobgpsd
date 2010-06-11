module Mobgpsd

  class NMEA

    def initialize(x, y, z, h = Time.now, fix = 1, sat = 0, z2 = 0)
      @x, @y, @z, @z2, @h = x.to_f, y.to_f, z.to_f, z2, Time.at(h.to_i)
      @fix, @sat, @hz = fix, sat, 0.9
    end

    def coords
      val = []
      [@x,@y].each_with_index do |l,i|
        deg = l.to_i.abs
        min = (60 * (l.abs - deg)).to_i
        labs = (l * 1000000).abs / 1000000
        sec = ((((labs - labs.to_i) * 60) - ((labs - labs.to_i) * 60).to_i) * 100000) * 60 / 100000
        out = "%.i%.2i%05.2f," % [deg,min,sec]
        if i == 0
          out += l > 0 ? "N" : "S"
        else
          out += l > 0 ? "E" : "W"
        end
        val << out
      end
      val.join(",")
    end

    def hour
      @h.strftime("%H%M%S")
    end

    def csum(str)
      str.each_byte.inject(0) { |i,s| i ^ s }.to_s(16)
    end

    def to_s
      str = "GPGGA,#{hour},#{coords},#{@fix},#{@sat},#{@hz},#{@z},M,#{@z2},M,,"
      #str = "GPRMC,#{hour},#{coords},#{@fix},#{@sat},#{@hz},#{@z},M,#{@z2},M,,"
      "$#{str}*#{csum(str)}"
    end
  end

end
