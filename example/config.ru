run Proc.new { |env| [200, {'Content-Type' => 'text/html'}, ["Hello, World from #{Thread.current.object_id}"]] }
