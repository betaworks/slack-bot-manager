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

# via https://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb

# from ActiveSupport::Inflector...
unless ''.respond_to?(:constantize)
  class String
    def constantize
      names = self.split('::')
      Object.const_get(self) if names.empty?
      names.shift if names.size > 1 && names.first.empty?
      names.inject(Object) do |constant, name|
        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          constant = constant.ancestors.inject do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end

          constant.const_get(name, false)
        end
      end
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
