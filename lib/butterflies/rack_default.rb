module Rack::Handler
  def self.default(options = {})
    Rack::Handler::Butterflies
  end
end
