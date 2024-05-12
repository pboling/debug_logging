require_relative "lamb_darts/benchmarked"
require_relative "lamb_darts/enter_log"
require_relative "lamb_darts/error_handle"
require_relative "lamb_darts/exit_log"
require_relative "lamb_darts/notify"

module DebugLogging
  module LambDartable
    module Log
      class << self
        def included(base)
          base.include(LambDarts::Benchmarked)
          base.include(LambDarts::EnterLog)
          base.include(LambDarts::ErrorHandle)
          base.include(LambDarts::ExitLog)
        end

        def extended(base)
          base.extend(LambDarts::Benchmarked)
          base.extend(LambDarts::EnterLog)
          base.extend(LambDarts::ErrorHandle)
          base.extend(LambDarts::ExitLog)
        end
      end
    end

    module Note
      class << self
        def included(base)
          base.include(LambDarts::ErrorHandle)
          base.include(LambDarts::Notify)
        end

        def extended(base)
          base.extend(LambDarts::ErrorHandle)
          base.extend(LambDarts::Notify)
        end
      end
    end
  end
end
