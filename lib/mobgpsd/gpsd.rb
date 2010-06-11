require "socket"
require "pty"
require "expect"

WT = 0.033 # 33ms

module Mobgpsd


  class GPSD

    def initialize(sock = "/tmp/gpsd.sock")
      # @conn = UNIXSocket.new(sock) rescue nil
      @pty_queue = Queue.new
      pty
    end

    def <<(v)
      @pty_queue << v.to_s + "\r\n"
    end

    # Thanks to manveru VER code
    def pty
      queue = @pty_queue
      Thread.new do
        shell = ENV['SHELL'] || 'bash'
        #shell = @cmd

        PTY.spawn(shell) do |r_pty, w_pty, pid|
          p "start #{r_pty.inspect}"
          Thread.new do
            while chunk = queue.shift
              #p "writing #{chunk}"
              w_pty.print chunk
              w_pty.flush
            end
          end
          begin
            loop do
              c = r_pty.sysread(1 << 15)
              on_chunk(c) if c
            end
          rescue Errno::EIO, PTY::ChildExited
            destroy
          end
        end
      end
    rescue Errno::EIO, PTY::ChildExited
      destroy
    end

    def add_self(p)
      # @conn.send("+%s\r\n" % p.path, 0) if @conn
    end

    def close
      # @conn.close
    end

  end

end
