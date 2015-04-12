module Mocks
  class Allow(T)
    getter subject

    def initialize(@subject : T)
    end

    def to(message)
      Mocks::Registry
        .for(subject.class.name)
        .fetch_method(message.method_name)
        .store_stub(subject.object_id, message.args, message.value)
    end
  end
end
