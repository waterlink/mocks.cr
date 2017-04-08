require "./spec_helper"

module SpiesTest
  class Person
    def greet(who)
      "hello #{who}"
    end
  end

  Mocks.create_mock SpiesTest::Person do
    mock greet(who)
  end

  module ExampleModule
    def self.greet(who)
      "hey #{who} from module"
    end

    def self.foo
      "hello world"
    end
  end

  Mocks.create_module_mock SpiesTest::ExampleModule do
    mock self.greet(who)
    mock self.foo
  end

  describe "Spies" do
    expectation = Mocks::HaveReceivedExpectation
      .new(receive(greet("world")))

    it "fails when there was no call" do
      p = Person.new
      expectation.match(p).should eq(false)
      expectation.failure_message(p)
        .should eq("expected: greet[\"world\"]\n     got: nil")
    end

    it "suceeds when there was a call" do
      p = Person.new
      p.greet("world")
      expectation.match(p).should eq(true)
      expectation.negative_failure_message(p)
        .should eq("expected: receive != greet[\"world\"]\n     got: greet[\"world\"]")
    end

    it "fails when there was a call with different arguments" do
      p = Person.new
      p.greet("John")
      expectation.match(p).should eq(false)
      expectation.failure_message(p)
        .should eq("expected: greet[\"world\"]\n     got: greet[\"John\"]")
    end

    it "works as stdlib spec expectation" do
      p = Person.new
      expect_raises Spec::AssertionFailed, "expected: greet[\"John\"]\n     got: nil" do
        p.should have_received(greet("John"))
      end

      p.greet("John")
      expect_raises Spec::AssertionFailed, "expected: greet[\"world\"]\n     got: greet[\"John\"]" do
        p.should have_received(greet("world"))
      end

      p.greet("John")
      expect_raises Spec::AssertionFailed, "expected: receive != greet[\"John\"]\n     got: greet[\"John\"]" do
        p.should_not have_received(greet("John"))
      end

      p.greet("world")
      p.should have_received(greet("world"))
    end

    it "works with module mock" do
      ExampleModule.greet("John")
      ExampleModule.should have_received(self.greet("John"))
    end

    it "works with module mock and no args" do
      ExampleModule.foo
      ExampleModule.should have_received(self.foo)
    end
  end
end
