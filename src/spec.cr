require "spec"
require "./mocks"

module Mocks
end

Spec.before_each do
  Mocks.reset
end

Spec.after_each do
  Mocks.reset
end
