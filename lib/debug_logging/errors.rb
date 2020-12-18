module DebugLogging
  class Error < StandardError; end

  class TimeoutError < Error; end

  class NoBlockGiven < Error; end
end
