# via https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/array/extract_options.rb

# Add extract_options! used in ActiveSupport
unless {}.respond_to?(:extractable_options?)
  class Hash
    def extractable_options?
      instance_of?(Hash)
    end
  end
end

unless [].respond_to?(:extract_options!)
  class Array
    def extract_options!
      last.is_a?(Hash) && last.extractable_options? ? pop : {}
    end
  end
end

# Allow removing methods from Slack::RealTime::Client
module Slack
  module RealTime
    class Client
      def off(type)
        type = type.to_s
        callbacks.delete(type) if callbacks.key?(type)
      end
    end
  end
end
