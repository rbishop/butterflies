require "http/parser"
require "stringio"

module Indian
  class Acceptor
    attr_reader :thr

    def initialize(app)
      @app = app
      accept
    end

    def accept
      @thr = Thread.new do
        socket = Socket.new(:INET, :STREAM)
        socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, 1)
        sockaddr = Socket.pack_sockaddr_in(3000, 'localhost')
        socket.bind(sockaddr)
        socket.listen(1024)

        loop do
          client, _ = socket.accept
          parser = Http::Parser.new(self)
          parser << client.readpartial(1024)
        
          status, headers, body = @app.call(env.merge(header_vars(parser.headers)))
          client.write "HTTP/1.1 200 OK\r\n"
          headers.each_pair {|key, value| client.write "#{key}: #{value}\r\n"}
          client.write "\r\n"
          body.each {|chunk| client.write chunk }
          body.close if body.respond_to? :close
          client.close
        end
      end
    end

    def join
      @thr.join
    end

    def env
      {
        "REQUEST_METHOD" => "GET",
        "SCRIPT_NAME" => "",
        "PATH_INFO" => "",
        "QUERY_STRING" => "",
        "SERVER_NAME" => "Indian #{Indian::VERSION}",
        "SERVER_PORT" => "3000",
        "rack.version" => Rack::VERSION,
        "rack.url_scheme" => "http",
        "rack.multithread" => true,
        "rack.multiprocess" => false,
        "rack.run_once" => false,
        "rack.input" => StringIO.new.set_encoding(Encoding::ASCII_8BIT),
        "rack.errors" => $stderr
      }
    end

    def header_vars(headers)
      hdrs = {}
      headers.each_pair do |key, value|
        hdrs["HTTP_#{key.upcase.gsub("-", "_")}"] = value
      end
      puts hdrs
      hdrs
    end
  end
end
