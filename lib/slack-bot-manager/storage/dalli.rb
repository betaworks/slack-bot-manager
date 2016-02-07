require 'dalli'

module SlackBotManager
  module Storage
    class Dalli
      attr_accessor :connection

      def initialize(options)
        if options.is_a?(Dalli)
          @connecton = options
        else
          servers = options.delete(:servers)
          @connection = ::Dalli::Client.new(servers, options)
        end
      end

      def pipeline(&block)
        yield block
      end

      def get_all(type)
        connection.get(type) || {}
      end

      def get(type, key)
        connection.get(type).try(key)
      end

      def set(type, key, val)
        obj = get_all(type).merge(key => val)
        connection.set(type, obj)
      end

      def multiset(type, *args)
        vals = args.extract_options!
        obj = get_all(type).merge(vals)
        connection.set(type, obj)
      end

      def delete(type, key)
        obj = get_all(type)
        obj.delete(key)
        connection.set(type, obj)
      end

      def delete_all(type)
        connection.delete(type)
      end

      # def expire(key, len)
      #   connection.expire(key, len)
      # end

      # def exists(type)
      #   connection.exists(key)
      # end

      # def incrby(type, key, incr=1)
      #   # TODO
      # end
    end
  end
end
