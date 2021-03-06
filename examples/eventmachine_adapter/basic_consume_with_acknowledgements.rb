#!/usr/bin/env ruby
# encoding: utf-8

__dir = File.dirname(File.expand_path(__FILE__))
require File.join(__dir, "example_helper")

amq_client_example "Acknowledge a message using basic.ack" do |client|
  channel = AMQ::Client::Channel.new(client, 1)
  channel.open do
    puts "Channel #{channel.id} is now open!"
  end

  queue = AMQ::Client::Queue.new(client, channel)
  queue.declare

  queue.bind("amq.fanout") do
    puts "Queue #{queue.name} is now bound to amq.fanout"
  end

  queue.consume do |_, consumer_tag|
    queue.on_delivery do |qu, header, payload, consumer_tag, delivery_tag, redelivered, exchange, routing_key|
      puts "Got a delivery: #{payload} (delivery tag: #{delivery_tag}), ack-ing..."

      qu.acknowledge(delivery_tag)
    end

    exchange = AMQ::Client::Exchange.new(client, channel, "amq.fanout", :fanout)
    10.times do |i|
      exchange.publish("Message ##{i}")
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
