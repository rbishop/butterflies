require 'rack/handler'
require 'indian'

module Rack
  module Handler
    module Indian
      def self.run(app, opts = {})
        master = ::Indian::Master.new(app)

        puts "Indian #{::Indian::VERSION} starting..."
        puts "* Process ID #{Process.pid}"
        puts "* Environment: #{ENV['RACK_ENV']}"
        puts "* Listening on localhost:3000"

        begin
          master.run
        rescue Interrupt
          puts "* Shutting down..."
          master.stop
          puts "* See-ya!"
        end
      end
    end

    register :indian, Indian
  end
end
