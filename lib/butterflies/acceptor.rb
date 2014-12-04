require "http/parser"
require "stringio"
require "io/wait"

Thread.abort_on_exception = true

module Butterflies
  class Acceptor
    attr_reader :thr

    def initialize(app)
      @app = app
      accept
    end

    def accept
      @thr = Thread.new do
        puts "Spawning: #{Thread.current.object_id}"
        server = Socket.new(:INET, :STREAM)
        server.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, 1)
        sockaddr = Socket.pack_sockaddr_in(3000, '127.0.0.1')
        server.bind(sockaddr)
        server.listen(1024)

        loop do
          begin
            client, _ = server.accept_nonblock
            puts Thread.current.object_id

            parser = Http::Parser.new(self)
            eof = false
            parser.on_headers_complete = proc { eof = true }

            until eof
              body = client.read_nonblock(64, exception: false)
              parser << body unless body == :wait_readable || body.nil?

              if body == :wait_readable && !eof
                IO.select([client])
                next
              end
            end
            
            status, headers, body = @app.call(env.merge(header_vars(parser.headers)))
            response = headers.reduce("HTTP/1.1 #{status} OK\r\n") do |res, (key, value)|
              res += "#{key}: #{value}\r\n"
            end

            response += "\r\n" 
            body.each do |line|
              response += line
            end

            until response == ""
              bytes = client.write_nonblock(response, exception: false)

              if bytes == :wait_writeable
                puts 'selecting'
                IO.select(nil, [client])
                next
              end

              response = response.byteslice(bytes..-1)
            end
            
            body.close
            client.close
          rescue IO::WaitReadable
            IO.select([server])
            next
          end
        end
      end

      @thr
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
        "SERVER_NAME" => "Butterflies #{Butterflies::VERSION}",
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
      hdrs
    end
  end
end
