module Mocks
  class Allow(T)
    getter subject

    def self.with_stubs(subject, stubs)
      stubs.each do |message|
        new(subject).to message
      end
      subject
    end

    def initialize(@subject : T)
    end

    def to(message)
      Mocks::Registry
        .for(subject_name)
        .fetch_method(message.method_name)
        .store_stub(object_id, message.args, message.value)
    end

    private def subject_name(subject : Class)
      subject.to_s
    end

    private def subject_name(subject)
      subject.class.name
    end

    private def subject_name
      subject_name(subject)
    end

    private def object_id
      Registry::ObjectId.build(subject)
    end
  end
end
