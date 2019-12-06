require "singleton"

module Mocks
  REGISTRIES = [] of Registry.class

  def self.reset_registries
    Singleton.reset

    Registry::Method::LAST_ARGS.keys.each do |key|
      Registry::Method::LAST_ARGS.delete(key)
    end
  end

  class RegistryInstances(T)
    getter get : Hash(String, T)
    def initialize
      @get = {} of String => T
    end

    def self.instance
      Singleton::Of(self).instance
    end
  end

  class Registry(T)
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

      def inspect(io)
        io << "ObjectId{#{value}}"
      end

      protected getter value
    end

    class CallHashKey(T)
      @object_id : ObjectId
      @args : T
      protected getter object_id
      protected getter args
      def initialize(@object_id, @args)
      end

      def ==(other : CallHashKey(T))
        self.object_id == other.object_id &&
          self.args == other.args
      end

      def hash
        (object_id.hash >> 2) + (args.hash >> 2)
      end

      def inspect(io)
        io << "CallHashKey(#{T}){#{object_id.inspect}, #{args.inspect}}"
      end
    end

    class CallHash(T)
      @hash : Hash(CallHashKey(T), ResultInterface)
      getter hash

      def initialize
        @hash = {} of CallHashKey(T) => ResultInterface
      end

      def add(object_id, args : T, result)
        hash[CallHashKey(T).new(object_id, args)] = ResultWrapper.new(result)
      end

      def fetch(object_id, args : T, result)
        hash.fetch(CallHashKey(T).new(object_id, args), ResultWrapper.new(result)).result
      end
    end

    class LastArgsKey
      protected getter registry_name
      protected getter name
      protected getter object_id
      def initialize(@registry_name : String, @name : String, @object_id : ObjectId)
      end

      def ==(other : LastArgsKey)
        self.registry_name == other.registry_name &&
          self.name == other.name &&
          self.object_id == other.object_id
      end

      def hash
        (@registry_name.hash >> 3) + (@name.hash >> 3) + (@object_id.hash >> 3)
      end

      def inspect(io)
        io << "LastArgsKey{registry_name=#{@registry_name.inspect},name=#{@name.inspect},object_id=#{@object_id.inspect}}"
      end
    end

    class Method(T)
      LAST_ARGS = {} of LastArgsKey => String
      RUNTIME = {:recording => true}

      @stubs : CallHash(T)
      @received : CallHash(T)
      @registry_name : String
      @name : String
      getter stubs, received, registry_name, name
      def initialize(registry_name, name)
        @registry_name = registry_name
        @name = name
        @stubs = CallHash(T).new
        @received = CallHash(T).new
      end

      def call(object_id, args)
        record_call(object_id, args)
        stubs.fetch(object_id, args, Result.new(true, nil))
      end

      def store_stub(object_id, args, value)
        stubs.add(object_id, args, Result.new(false, value))
      end

      def received?(object_id, args)
        received
          .fetch(object_id, args, Result.new(true, false))
          .value
      end

      def last_received_args(object_id)
        LAST_ARGS[LastArgsKey.new(registry_name, name, object_id)]?
      end

      private def record_call(object_id, args)
        return unless recording?

        begin
          disable_recording
          received.add(object_id, args, Result.new(false, true))
          LAST_ARGS[LastArgsKey.new(registry_name, name, object_id)] = args ? args.to_a.inspect : "[]"
        ensure
          enable_recording
        end
      end

      private def recording?
        RUNTIME[:recording]
      end

      private def enable_recording
        RUNTIME[:recording] = true
      end

      private def disable_recording
        RUNTIME[:recording] = false
      end
    end

    def self.for(name)
      instances[name] = instances.fetch(name) {
        new(name)
      }
    end

    def self.instances
      RegistryInstances(self).instance.get
    end

    @methods : Hash(String, Method(T))
    @name : String
    getter methods

    def initialize(@name)
      @methods = {} of String => Method(T)
    end

    def fetch_method(method_name)
      methods[method_name] = methods.fetch(method_name) {
        Method(T).new(@name, method_name)
      }
    end

    macro remember(t)
    end

    class Result(T)
      @call_original : Bool
      @value : T
      getter call_original, value

      def initialize(@call_original, @value : T)
      end
    end
  end
end
