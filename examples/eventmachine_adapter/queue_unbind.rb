#!/usr/bin/env ruby
# encoding: utf-8

__dir = File.dirname(File.expand_path(__FILE__))
require File.join(__dir, "example_helper")

amq_client_example "Bind and then unbind a queue to amq.fanout" do |client|
  channel = AMQ::Client::Channel.new(client, 1)
  channel.open do
    puts "Channel #{channel.id} is now open!"
  end

  queue = AMQ::Client::Queue.new(client, channel, "amqclient.queue2")
  queue.declare do
    puts "Queue #{queue.name.inspect} is now declared!"
  end

  queue.bind("amq.fanout") do
    puts "Queue #{queue.name} is now bound to amq.fanout"

    queue.unbind("amq.fanout") do
      puts "Queue #{queue.name} is now unbound from amq.fanout"

      puts
      puts "Deleting queue #{queue.name}"
      queue.delete do |_, message_count|
        puts "Deleted."
        puts
        client.disconnect do
          puts
          puts "AMQP connection is now properly closed"
          EM.stop
        end
      end
    end
  end
end
