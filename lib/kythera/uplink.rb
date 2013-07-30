class Uplink
  attr_reader :config

  def initialize(config)
    @config    = config
    @connected = false
    @socket    = nil
  end

  public

  def connected?
    @connected
  end

  def connect(socket = nil)
    if not @socket
      begin
        @socket = TCPSocket.new(@config.host, @config.port)
      rescue Exception => err
        raise DisconnectedError, err
      else
        @connected = true
      end
    end

    @socket = socket if socket

    self
  end

  def read
    begin
      data = @socket.read_nonblock 8192
    rescue IO::WaitReadable
      return # Will go back to select and try again
    rescue Exception => err
      raise DisconnectedError, err
    end

    raise DisconnectedError, "empty read" if not data or data.empty?

    data
  end

  def write(line)
    line += "\r\n"

    begin
      written = @socket.write_nonblock(line)
    rescue IO::WaitWritable
      return # Will go back to select and try again
    rescue Exception => err
      raise DisconnectedError, err
    end

    written
  end

  class DisconnectedError < Exception
  end
end
