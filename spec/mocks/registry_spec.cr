require "../spec_helper"

macro method_for(name, method_name, args)
  Registry(typeof({{args}}))
    .for({{name}})
    .fetch_method({{method_name}})
end

module Mocks
  class Registry
    describe Method do
      describe "#received?(object_id, args)" do
        it "is false when there were no such call" do
          oid = ObjectId.new(375_u64)

          method_for("Example", "say", nil).received?(oid, nil)
            .should eq(false)

          method_for("Example", "say", {"hello world"}).received?(oid, {"hello world"})
            .should eq(false)
        end

        it "is true when there was such call" do
          oid = ObjectId.new(375_u64)

          m = method_for("Example", "say", nil)
          m.call(oid, nil)
          m.received?(oid, nil).should eq(true)

          m = method_for("Example", "say", {"hello world"})
          m.call(oid, {"hello world"})
          m.received?(oid, {"hello world"}).should eq(true)
        end

        it "is false when arguments are different" do
          oid = ObjectId.new(983_u64)
          m = method_for("Example", "say", {"hello world"})

          m.call(oid, {"hello test"})
          m.received?(oid, {"hello test"}).should eq(true)
          m.received?(oid, {"hello world"}).should eq(false)
        end
      end

      describe "#last_received_args(object_id)" do
        it "returns nil when there were no call" do
          m = method_for("Example", "say", {"hello"})
          oid = ObjectId.new(983_u64)
          m.last_received_args(oid).should eq(nil)
        end

        it "returns arguments of last call" do
          m_nil = method_for("Example", "say", nil)
          m_str = method_for("Example", "say", {"test"})
          oid1 = ObjectId.new(983_u64)
          oid2 = ObjectId.new(777_u64)

          m_nil.call(oid1, nil)
          m_nil.last_received_args(oid1).should eq("[]")
          m_str.last_received_args(oid1).should eq("[]")

          m_str.call(oid1, {"hello world"})
          m_nil.call(oid1, nil)
          m_str.last_received_args(oid1).should eq("[]")
          m_nil.last_received_args(oid1).should eq("[]")

          m_str.call(oid2, {"hello world"})
          m_str.call(oid2, {"hello test"})
          m_str.last_received_args(oid1).should eq("[]")
          m_nil.last_received_args(oid1).should eq("[]")

          m_str.last_received_args(oid2).should eq(["hello test"].inspect)
          m_nil.last_received_args(oid2).should eq(["hello test"].inspect)

          m_str.call(oid1, {"hello world"})
          m_nil.last_received_args(oid1).should eq(["hello world"].inspect)
          m_str.last_received_args(oid1).should eq(["hello world"].inspect)
        end
      end
    end
  end
end
