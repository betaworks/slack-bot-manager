require 'redis'

module SlackBotManager
  module Storage
    class Redis
      attr_accessor :connection

      def initialize(connection)
        @connection = connection
      end

      def pipeline(&block)
        connection.pipelined do
          block.call
        end
      end

      def get_all(type)
        connection.hgetall(type)
      end

      def get(type,key)
        connection.get(type,key)
      end

      def set(type,key,val)
        connection.hset(type,key,val)
      end

      def multiset(type,*args)
        connection.hmset(type,*args)
      end

      def delete(type,key)
        connection.hdel(type,key)
      end

      def delete_all(type)
        connection.del(type)
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
