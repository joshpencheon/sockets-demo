#!/usr/bin/env ruby

require "socket"

def main
  case (command = ARGV[0])
  when "start", nil
    server = TCPServer.open("localhost", 0)
    client = await_connection_to(server)
    loop { send_input_to(client) }
  when "connect"
    port = ARGV[1].to_i
    socket = TCPSocket.open("localhost", port)
    puts "\ec"
    print(socket.getc) while true
  else
    warn "Unknown command: #{command.inspect}"
    exit 1
  end
end

def await_connection_to(server)
  puts <<~SETUP
    \ecServer started; run the following in a new window:

      ./demo.rb connect #{server.addr[1]}

    Waiting for connection...
  SETUP

  client = server.accept

  puts <<~INSTRUCTIONS
    \ecNow connected. Enter sequences to be sent into the prompt.
  INSTRUCTIONS

  client
end

def send_input_to(client)
  print "> "

  escaped_chars = $stdin.gets.chomp
  chars = eval('"' + escaped_chars + '"').chars

  if chars.any?
    puts "         | #{chars.map.with_index { |c,i| i.to_s.center(c.inspect.length)}.join(" | ")} |"
    puts "sending: | #{chars.map { |c| c.inspect }.join(" | ")} |"
  end

  chars.each { |chr| client.print(chr) }
rescue SyntaxError
  puts %{Failed to evaluate: #{escaped_chars}}
end

main
