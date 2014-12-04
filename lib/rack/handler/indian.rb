require 'rack/handler'
require 'butterflies'

module Rack
  module Handler
    module Butterflies
      def self.run(app, opts = {})
        master = ::Butterflies::Master.new(app)

        puts "Butterflies #{::Butterflies::VERSION} starting..."
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

    register :butterflies, Butterflies
  end
end
