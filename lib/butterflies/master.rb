module Butterflies
  class Master
    
    def initialize(app)
     @app = app
    end

    def run
      @acceptors = 4.times.map { Acceptor.new(@app) }
      @acceptors.map(&:join)
    end
  end
end
