require "mongo"
gem "mongo_ext" # terrible bug w/o this

module Mobgpsd

  class Store
    def initialize(params={})
      host, port = params[:host] || "localhost", params[:port] || 27017
      @conn = Mongo::Connection.new(host, port)
      @db = @conn.db(params[:dbname] || "mobgpsd")
      setup
    end

    def fixes;     @db.collection("fixes");     end
    def count;     fixes.count;                 end
    def drop;      fixes.drop;                  end

    def setup
      fixes.create_index([["id", Mongo::ASCENDING], ["hour", Mongo::ASCENDING]])
      fixes.create_index([["geom", Mongo::GEO2D]], :min => -180, :max => 180)
    end

    def <<(hsh)
      if hsh.is_a? Array
        x, y, h = hsh
        hsh = {"geom" => [x,y], "hour" => h }
      end
      hsh["geom"][0] = sin_proj(hsh["geom"])[0] if hsh["geom"]
      fixes.insert(hsh)
    end


    private

    def sin_proj(x,y=nil)
      x,y = x unless y
      [x * Math.cos(y * Math::PI/180), y]
    end
  end

end
