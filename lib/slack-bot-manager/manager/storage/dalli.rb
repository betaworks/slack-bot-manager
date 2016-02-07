require 'dalli'

module SlackBotManager
  module Storage
    class Dalli
      attr_accessor :connection

      def initialize(connection)
        @connection = connection
      end

      def pipeline(&block)
        block.call
      end

      def get_all(type)
        connection.get(type)
      end

      def get(type,key)
        connection.get(type)[key]
      end

      def set(type,key,val)
        obj = get(type).merge({key => val})
        connection.set(type,obj)
      end

      def multiset(type,*args)
        vals = args.extract_options!
        obj = get(type).merge(vals)
        connection.set(type,*args)
      end

      def delete(type,key)
        obj = get(type)
        val = obj.delete(key)
        connection.set(type,obj)
      end

      def delete_all(type)
        connection.delete(type)
      end

      # def expire(key,len)
      #   connection.expire(key,len)
      # end

      # def exists(type)
      #   connection.exists(key)
      # end

      # def incrby(type,key,incr=1)
      #   # TODO
      # end
    end
  end
end
