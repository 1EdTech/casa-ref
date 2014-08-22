require 'thin'

module Rack
  module Handler
    class Thin

      def self.casa_server_config= value
        @@casa_server_config = value
      end

      def self.casa_server_config
        @@casa_server_config
      end

      def self.run(app, options={})

        app = Rack::Chunked.new(Rack::ContentLength.new(app))

        server = ::Thin::Server.new(options[:Host] || self.casa_server_config['host'],
                                    options[:Port] || self.casa_server_config['port'],
                                    app)

        if self.casa_server_config.include?('ssl')
          server.ssl = true
          server.ssl_options = {
              :private_key_file => self.casa_server_config['ssl']['private_key_file'],
              :cert_chain_file => self.casa_server_config['ssl']['cert_chain_file']
          }
        end

        yield server if block_given?

        server.start

      end

    end
  end
end