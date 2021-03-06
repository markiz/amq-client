#!/usr/bin/env ruby
# encoding: utf-8

__dir = File.dirname(File.expand_path(__FILE__))
require File.join(__dir, "example_helper")

amq_client_example "Rollback acknowledgement transaction using tx.rollback" do |client|
  AMQ::Client::Channel.new(client, 1).open do |channel|
    channel.tx_select do |_|
      channel.tx_rollback do |_|
        puts "Transaction on channel #{channel.id} is now rolled back"
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
end
