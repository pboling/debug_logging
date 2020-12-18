# frozen_string_literal: true

# From: https://stackoverflow.com/a/34559282
# License: https://creativecommons.org/licenses/by-sa/4.0/
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