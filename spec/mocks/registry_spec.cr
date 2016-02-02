require "../spec_helper"

module Mocks
  class Registry
    describe Method do
      describe "#received?(object_id, args)" do
        it "is false when there were no such call" do
          m = Registry.for("example class").fetch_method("say")
          oid = ObjectId.new(375_u64)

          m.received?(oid).should eq(false)
          m.received?(oid, Args.new(["hello world"])).should eq(false)
        end

        it "is true when there was such call" do
          m = Registry.for("example class").fetch_method("say")
          oid = ObjectId.new(375_u64)

          m.call(oid)
          m.received?(oid).should eq(true)

          m.call(oid, Args.new(["hello world"]))
          m.received?(oid, Args.new(["hello world"])).should eq(true)
        end

        it "is false when arguments are different" do
          m = Registry.for("example class").fetch_method("say")
          oid = ObjectId.new(983_u64)

          m.call(oid, Args.new(["hello test"]))
          m.received?(oid, Args.new(["hello world"])).should eq(false)
        end
      end

      describe "#last_received_args(object_id)" do
        it "returns nil when there were no call" do
          m = Registry.for("example class").fetch_method("say")
          oid = ObjectId.new(983_u64)
          m.last_received_args(oid).should eq(nil)
        end

        it "returns arguments of last call" do
          m = Registry.for("example class").fetch_method("say")
          oid1 = ObjectId.new(983_u64)
          oid2 = ObjectId.new(777_u64)

          m.call(oid1)
          m.last_received_args(oid1).should eq(NoArgs.new)

          m.call(oid1, Args.new(["hello world"]))
          m.call(oid1)
          m.last_received_args(oid1).should eq(NoArgs.new)

          m.call(oid2, Args.new(["hello world"]))
          m.call(oid2, Args.new(["hello test"]))
          m.last_received_args(oid1).should eq(NoArgs.new)

          m.last_received_args(oid2).should eq(Args.new(["hello test"]))

          m.call(oid1, Args.new(["hello world"]))
          m.last_received_args(oid1).should eq(Args.new(["hello world"]))
        end
      end
    end
  end
end
