# From: https://stackoverflow.com/a/34559282
# License: https://creativecommons.org/licenses/by-sa/4.0/
module DebugLogging
  module Finalize
    def self.extended(obj)
      TracePoint.trace(:end) do |t|
        if obj == t.self
          if obj.respond_to?(:debug_finalize)
            obj.debug_finalize
          else
            warn("#{obj} does not define a debug_finalize")
          end
          t.disable
        end
      end
    end
  end
end
