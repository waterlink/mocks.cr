module Mocks
  class Registry
    class Method
      def initialize
        @stubs = Stubs.new
      end

      def call(object_id)
        stubs.fetch(object_id, NoArgs.new, Result.new(true, nil))
      end

      def call(object_id, args)
        stubs.fetch(object_id, args, Result.new(true, nil))
      end

      def store_stub(object_id, args, value)
        stubs.add(object_id, args, Result.new(false, value))
      end

      def stubs
        @stubs
      end
    end

    def self.for(name)
      instances[name] = instances.fetch(name) {
        new(name)
      }
    end

    def self.instances
      @@_instances ||= reset!
    end

    def self.reset!
      @@_instances = {} of String => self
    end

    @methods :: Hash(String, Method)
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
      @call_original :: Bool
      @value :: T
      getter call_original, value

      def initialize(@call_original, @value : T)
      end
    end

    class NoArgs
      def ==(other : NoArgs)
        true
      end

      def ==(other)
        false
      end

      def hash
        0
      end
    end

    module ArgsInterface
      abstract def ==(other)
      abstract def hash
      abstract def downcast
    end

    class Args(T)
      include ArgsInterface

      @value :: T
      getter value

      def initialize(@value : T)
      end

      def ==(other : ArgsInterface)
        self.value == other.value
      end

      def ==(other)
        false
      end

      def hash
        value.hash
      end

      def downcast
        self
      end
    end

    class ObjectId
      def self.build(object : Class)
        new(object.to_s)
      end

      def self.build(object)
        new(object.object_id)
      end

      def initialize(@value : String|typeof(nil.object_id))
      end

      def ==(other : ObjectId)
        self.value == other.value
      end

      def hash
        value.hash
      end

      protected getter value
    end

    class ResultWrapper
      getter result
      def initialize(@result)
      end
    end

    class StubKey
      @id :: ObjectId
      @args :: ArgsInterface
      getter id, args
      def initialize(@id, @args)
      end

      def ==(other : self)
        self.id == other.id &&
          self.args.downcast == other.args.downcast
      end

      def hash
        {id, args}.hash
      end
    end

    class Stubs
      getter hash

      def initialize
        @hash = {} of StubKey => ResultWrapper
      end

      def add(object_id, args, result)
        key = StubKey.new(object_id, Args.new(args))
        hash[key] = ResultWrapper.new(result)
      end

      def fetch(object_id, args, result)
        key = StubKey.new(object_id, Args.new(args))
        hash.fetch(key, ResultWrapper.new(result)).result
      end
    end
  end
end
