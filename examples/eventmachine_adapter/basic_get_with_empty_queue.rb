#!/usr/bin/env ruby
# encoding: utf-8

__dir = File.dirname(File.expand_path(__FILE__))
require File.join(__dir, "example_helper")

amq_client_example "Set a queue up for message delivery" do |client|
  channel = AMQ::Client::Channel.new(client, 1)
  channel.open do
    puts "Channel #{channel.id} is now open!"
  end

  queue = AMQ::Client::Queue.new(client, channel)
  queue.declare(false, false, false, true) do
    puts "Server-named, auto-deletable Queue #{queue.name.inspect} is ready"
  end

  queue.bind("amq.fanout") do
    puts "Queue #{queue.name} is now bound to amq.fanout"
  end
  sleep 0.1

  10.times do |i|
    queue.get(true) do |_, header, payload, delivery_tag, redelivered, exchange, routing_key, message_count|
      puts "basic.get callback has fired"
      puts
      puts "Payload is #{payload}"
      if header
        puts "header is #{header.decode_payload.inspect}"
      else
        puts "header is nil"
      end
      puts "delivery_tag is #{delivery_tag.inspect}"
      puts "redelivered is #{redelivered.inspect}"
      puts "exchange is #{exchange.inspect}"
      puts "routing_key is #{routing_key.inspect}"
      puts "message_count is #{message_count.inspect}"
    end
  end

  show_stopper = Proc.new {
    client.disconnect do
      puts
      puts "AMQP connection is now properly closed"
      EM.stop
    end
  }

  Signal.trap "INT",  show_stopper
  Signal.trap "TERM", show_stopper
end
