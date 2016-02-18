module Mocks
  class Registry
    module ResultInterface
      abstract def result
      abstract def downcast
    end

    class ResultWrapper(T)
      include ResultInterface

      @result : T
      getter result
      def initialize(@result : T)
      end

      def downcast
        self
      end
    end

    class ObjectId
      def self.build(object)
        if object.responds_to?(:object_id)
          new(object.object_id)
        else
          new(object.to_s)
        end
      end

      @value : String|UInt64
      def initialize(@value)
      end

      def ==(other : ObjectId)
        self.value == other.value
      end

      def hash
        value.hash
      end

      protected getter value
    end

    module ArgsInterface
      abstract def ==(other)
      abstract def hash
      abstract def downcast
    end

    class Args(T)
      include ArgsInterface

      @value : T
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

    class StubKey
      @id : ObjectId
      @args : ArgsInterface
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

    class CallHash
      @hash : Hash(StubKey, ResultInterface)
      getter hash

      def initialize
        @hash = {} of StubKey => ResultInterface
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

    class Method
      @stubs : CallHash
      @received : CallHash
      @last_args : CallHash
      getter stubs, received, last_args
      def initialize
        @stubs = CallHash.new
        @received = CallHash.new
        @last_args = CallHash.new
      end

      def call(object_id)
        call(object_id, NoArgs.new)
      end

      def call(object_id, args)
        received.add(object_id, args, Result.new(false, true))
        last_args.add(object_id, NoArgs.new, Result.new(false, args))
        stubs.fetch(object_id, args, Result.new(true, nil))
      end

      def store_stub(object_id, args, value)
        stubs.add(object_id, args, Result.new(false, value))
      end

      def received?(object_id)
        received?(object_id, NoArgs.new)
      end

      def received?(object_id, args)
        received
          .fetch(object_id, args, Result.new(true, false))
          .value
      end

      def last_received_args(object_id)
        last_args
          .fetch(object_id, NoArgs.new, Result.new(true, nil))
          .value
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

    @methods : Hash(String, Method)
    @name : String
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
      @call_original : Bool
      @value : T
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
  end
end
