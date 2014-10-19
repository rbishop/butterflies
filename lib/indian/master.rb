module Indian
  class Master
    
    def initialize(app)
     @app = app
    end

    def run
      @acceptors = 16.times.map { Acceptor.new(@app) }
      @acceptors.map(&:join)
    end
  end
end
