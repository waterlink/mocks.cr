module Mocks
  class Registry
    def self.for(name)
      instances[name] = instances.fetch(name) {
        new(name)
      }
    end

    def self.instances
      @@_instances ||= {} of String => self
    end

    getter methods

    def initialize(@name)
      @methods = {} of String => Method
    end

    def fetch_method(method_name)
      methods[method_name] = methods.fetch(method_name) {
        Method.new
      }
    end

    class Result(T)
      getter call_original, value

      def initialize(@call_original, @value : T)
      end
    end

    class Method
      getter stubs

      def initialize
        @stubs = {} of Array(Object) => Result
      end

      def call(object_id, args)
        stubs.fetch([object_id, args], Result.new(true, nil))
      end

      def store_stub(object_id, args, value)
        stubs[[object_id, args]] = Result.new(false, value)
      end
    end
  end
end
