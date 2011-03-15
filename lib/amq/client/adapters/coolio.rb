# encoding: utf-8

# http://coolio.github.com

require "cool.io"
require "amq/client"

require "amq/client/io/string"

module AMQ
  module Client
    class Coolio
      class Socket < ::Coolio::TCPSocket
        attr_accessor :adapter

        def self.connect(adapter, host, port)
          socket = super(host, port)
          socket.adapter = adapter
          socket
        end

        def on_connect
          #puts "On connect"
          adapter.on_socket_connect
        end

        def on_read(data)
          # puts "Received data"
          # puts_data(data)
          adapter.on_read(data)
        end

        # This handler should never trigger in normal circumstances
        def on_close
          adapter.on_socket_disconnect
        end

        def send_raw(data)
          # puts "Sending data"
          # puts_data(data)
          write(data)
        end

        protected
        def puts_data(data)
          puts "    As string:     #{data.inspect}"
          puts "    As byte array: #{data.bytes.to_a.inspect}"
        end
      end

      # Behaviors
      include AMQ::Client::Adapter

      self.sync = false

      # API
      attr_accessor :socket
      attr_accessor :callbacks
      attr_accessor :connections

      class <<self
        def connect(settings, &block)
          settings        = self.settings.merge(settings)
          host, port      = settings[:host], settings[:port]
          instance        = new
          socket          = Socket.connect(instance, settings[:host], settings[:port])
          socket.attach Cool.io::Loop.default
          instance.socket = socket
          instance.on_connection(&block)
          instance
        end
      end

      def initialize
        @callbacks = {}
        @connections = []
        super
      end

      # sets a callback for connection
      def on_connection(&block)
        @callbacks[:connect] = block
      end

      # sets a callback for disconnection
      def on_disconnection(&block)
        @callbacks[:disconnect] = block
      end

      def on_open(&block)
        @callbacks[:open] = block
      end # on_open(&block)


      # called by AMQ::Client::Connection after we receive connection.open-ok.
      def connection_successful
        @callbacks[:connect].call(self) if @callbacks[:connect]
      end

      # called by AMQ::Client::Connection after we receive connection.close-ok.
      def disconnection_successful
        @callbacks[:disconnect].call(self) if @callbacks[:disconnect]
        close_connection
      end

      def open_successful
        @authenticating = false
        @callbacks[:open].call(self) if @callbacks[:open]
      end # open_successful


      # triggered when socket is connected but before handshake is done
      def on_socket_connect
        post_init
      end

      # triggered after socket is closed
      def on_socket_disconnect
      end

      def send_raw(data)
        socket.send_raw data
      end

      # The story about the buffering is kinda similar to EventMachine,
      # you keep receiving more than one frame in a single packet.
      def on_read(chunk)
        @chunk_buffer << chunk
        while frame = get_next_frame
          receive_frame(AMQ::Client::StringAdapter::Frame.decode(frame))
        end
      end

      def close_connection
        @socket.close
      end

      protected
      def post_init
        reset
        handshake
      end

      def reset
        @chunk_buffer = ""
      end

      def get_next_frame
        return nil unless @chunk_buffer.size > 7 # otherwise, cannot read the length
        # octet + short
        offset = 1 + 2
        # length
        payload_length = @chunk_buffer[offset, 4].unpack('N')[0]
        # 4 bytes for long payload length, 1 byte final octet
        frame_length = offset + 4 + payload_length + 1
        if frame_length <= @chunk_buffer.size
          @chunk_buffer.slice!(0, frame_length)
        else
          nil
        end
      end
    end
  end
end
