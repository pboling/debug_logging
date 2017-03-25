module DebugLogging
  module ArgumentPrinter
    def self.to_s(args)
      length = 0
      if DebugLogging.last_hash_to_s_proc && args[-1].is_a?(Hash)
        if args.length > 1
          add_args_ellipsis = false
          add_last_hash_ellipsis = false
          printed_args = args[0..(-2)].map {|x| x.inspect}.join(", ").tap {|x| add_args_ellipsis = x.length > DebugLogging.args_max_length}[0..(DebugLogging.args_max_length)]
          printed_args << DebugLogging.ellipsis if add_args_ellipsis
          printed_args << ", " << DebugLogging.last_hash_to_s_proc.call(args[-1]).tap {|x| add_last_hash_ellipsis = x.length > DebugLogging.last_hash_max_length}[0..(DebugLogging.last_hash_max_length)]
          printed_args << DebugLogging.ellipsis if add_last_hash_ellipsis
        else
          printed_args = DebugLogging.last_hash_to_s_proc.call(args[0]).tap {|x| add_last_hash_ellipsis = x.length > DebugLogging.last_hash_max_length}[0..(DebugLogging.last_hash_max_length)]
          printed_args << DebugLogging.ellipsis if add_last_hash_ellipsis
        end
      else
        add_args_ellipsis = false
        if args.length == 1 && args[0].is_a?(Hash)
          # handle double splat
          printed_args = ("**" << args.map {|x| x.inspect}.join(", ").tap {|x| add_args_ellipsis = x.length > DebugLogging.args_max_length})[0..(DebugLogging.args_max_length)]
        else
          printed_args = args.map {|x| x.inspect}.join(", ").tap {|x| add_args_ellipsis = x.length > DebugLogging.args_max_length}[0..(DebugLogging.args_max_length)]
        end
        printed_args << DebugLogging.ellipsis if add_args_ellipsis
      end
      "(#{printed_args})"
    end
  end
end
