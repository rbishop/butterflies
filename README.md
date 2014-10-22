# Indian

Indian is an experimental web server for Ruby applications that takes 
advantage of modern Linux kernel (version 3.14+) features and threads.

## Design

Indian is inspired by the Erlang HTTP web server Cowboy. While we can't emulate
everything Cowboy does in Ruby, due to the differences between Ruby and Erlang,
we can borrow a little bit from Cowboy's design.

Cowboy works by spawning a listening socket and then sharing that socket with a
pool (potentially thousands of acceptors) of Erlang processes that accept on
the socket. Erlang's unit of concurrency is known as a process. Erlang
processes spawn very quickly so this model works well. In Ruby we have threads
for concurrency, which unfortunately don't spawn that fast. It is best to spawn
the threads you need upfront and re-use them.

The two premier Ruby web servers today, Unicorn and Puma, work in very
interesting and different ways. Unicorn is a lot like Cowboy in that it shares
a listening socket among many child processes that then accept on this socket.
The problem is that Unicorn's processes are operating processes which consume a
lot more memory than a Thread or an Erlang process. This also means one process
is only ever handling one request at a time. The advantage of this approach is
that the kernel of the underlying operating system load balances requests for
you.

Puma works by using threads for handling requests. Puma manages this by having
a thread listen for new connections and then pushing the connections onto a
queue. There is then a pool of threads that monitor and handle requests. Puma
also has a Reactor where you can check-in long lived connections.This is ideal
because regardless of the runtime you're using you can serve more than one
request in parallel per operating system process. The disadvantage is that you
have only one acceptor and have to manage the log of waiting connections
instead of letting the operating systen kernel do this for you.

Like Puma, Indian is designed using threads. Indian takes advantage of the
`SO_REUSEPORT` socket option that is available in Linux kernel version 3.9+ and
BSD operating systems. Each Indian thread can listen and accept connections on
the same port.  The back log of connections will be load balanced by the
underlying kernel so you get performance and reliability without having to
manage that complexity yourself.  You get the simplicity of Unicorn with the
parallel request handling of Puma!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'indian'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install indian

## Usage

This gem is not ready to be used yet.

## TODO

- [ ] epoll FFI binding for Ruby or just use nio4r
- [ ] TCP_FASTOPEN (Linux kernel 3.7+)
- [ ] TCP_AUTOCORKING (Linux kernel 3.14+)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/indian/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
