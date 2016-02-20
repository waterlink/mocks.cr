require "spec"
require "./mocks"

module Mocks
end

include ::Mocks::Macro::GlobalDSL

Spec.before_each do
  Mocks.reset
end

Spec.after_each do
  Mocks.reset
end
