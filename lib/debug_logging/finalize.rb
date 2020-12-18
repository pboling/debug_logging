# frozen_string_literal: true

module DebugLogging
  module Finalize
    def self.extended(obj)
      TracePoint.trace(:end) do |t|
        if obj == t.self
          obj.finalize
          t.disable
        end
      end
    end
  end
end