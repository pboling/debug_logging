module DebugLogging
  module ArgumentPrinter
    def debug_arguments_to_s(args: nil, config_proxy: nil)
      if config_proxy.debug_last_hash_to_s_proc && args[-1].is_a?(Hash)
        if args.length > 1
          add_args_ellipsis = false
          add_last_hash_ellipsis = false
          printed_args = args[0..(-2)].map {|x| x.inspect}.join(", ").tap {|x| add_args_ellipsis = x.length > config_proxy.debug_args_max_length}[0..(config_proxy.debug_args_max_length)]
          printed_args << config_proxy.debug_ellipsis if add_args_ellipsis
          printed_args << ", " << config_proxy.debug_last_hash_to_s_proc.call(args[-1]).tap {|x| add_last_hash_ellipsis = x.length > config_proxy.debug_last_hash_max_length}[0..(config_proxy.debug_last_hash_max_length)]
          printed_args << config_proxy.debug_ellipsis if add_last_hash_ellipsis
        else
          printed_args = config_proxy.debug_last_hash_to_s_proc.call(args[0]).tap {|x| add_last_hash_ellipsis = x.length > config_proxy.debug_last_hash_max_length}[0..(config_proxy.debug_last_hash_max_length)]
          printed_args << config_proxy.debug_ellipsis if add_last_hash_ellipsis
        end
      else
        add_args_ellipsis = false
        if args.length == 1 && args[0].is_a?(Hash)
          # handle double splat
          printed_args = ("**" << args.map {|x| x.inspect}.join(", ").tap {|x| add_args_ellipsis = x.length > config_proxy.debug_args_max_length})[0..(config_proxy.debug_args_max_length)]
        else
          printed_args = args.map {|x| x.inspect}.join(", ").tap {|x| add_args_ellipsis = x.length > config_proxy.debug_args_max_length}[0..(config_proxy.debug_args_max_length)]
        end
        printed_args << config_proxy.debug_ellipsis if add_args_ellipsis
      end
      "(#{printed_args})"
    end
  end
end
