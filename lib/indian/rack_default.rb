module Rack::Handler
  def self.default(options = {})
    Rack::Handler::Indian
  end
end
