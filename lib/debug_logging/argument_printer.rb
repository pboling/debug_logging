module DebugLogging
  module ArgumentPrinter
    def debug_benchmark_to_s(tms: nil)
      "completed in #{sprintf("%f", tms.real)}s (#{sprintf("%f", tms.total)}s CPU)"
    end
    def debug_invocation_id_to_s(args: nil, config_proxy: nil)
      if config_proxy.debug_add_invocation_id
        invocation = " ~#{args.object_id}@#{sprintf("%#-21a", Time.now.to_f)[4..(-4)]}~"
        case config_proxy.debug_add_invocation_id
        when true then
          invocation
        else
          config_proxy.debug_add_invocation_id.call(ColorizedString[invocation])
        end
      else
        ""
      end
    end
    def debug_invocation_to_s(klass: nil, separator: nil, method_to_log: nil, config_proxy: nil)
      klass_string = if config_proxy.debug_colorized_chain_for_class
                       config_proxy.debug_colorized_chain_for_class.call(ColorizedString[klass.to_s])
                     else
                       klass.to_s
                     end
      method_string = if config_proxy.debug_colorized_chain_for_method
                        config_proxy.debug_colorized_chain_for_method.call(ColorizedString[method_to_log.to_s])
                      else
                        method_to_log.to_s
                      end
      "#{klass_string}#{separator}#{method_string}"
    end
    def debug_signature_to_s(args: nil, config_proxy: nil)
      printed_args = ""
      add_args_ellipsis = false
      if config_proxy.debug_last_hash_to_s_proc && args[-1].is_a?(Hash)
        if args.length > 1
          add_last_hash_ellipsis = false
          if config_proxy.debug_multiple_last_hashes
            last_hash_args, other_args = args.partition do |arg|
                                            arg.is_a?(Hash)
                                          end
            other_args_string = other_args.map(&:inspect).join(", ").tap {|x| add_args_ellipsis = x.length > config_proxy.debug_args_max_length}[0..(config_proxy.debug_args_max_length)]
            last_hash_args_string = last_hash_args.map do |arg|
                                      String(config_proxy.
                                          debug_last_hash_to_s_proc.
                                          call(arg)).
                                          tap {|x|
                                                add_last_hash_ellipsis = x.length > config_proxy.debug_last_hash_max_length
                                              }[0..(config_proxy.debug_last_hash_max_length)].
                                          tap {|x|
                                                x << config_proxy.debug_ellipsis if add_last_hash_ellipsis
                                              }
                                    end.join(", ")
            printed_args << other_args_string if other_args_string
            printed_args << ", " if !other_args_string.empty? && !last_hash_args_string.empty?
            printed_args << last_hash_args_string if last_hash_args_string
          else
            printed_args << args[0..(-2)].map {|x| x.inspect}.join(", ").tap {|x| add_args_ellipsis = x.length > config_proxy.debug_args_max_length}[0..(config_proxy.debug_args_max_length)]
            printed_args << config_proxy.debug_ellipsis if add_args_ellipsis
            printed_args << ", " << config_proxy.debug_last_hash_to_s_proc.call(args[-1]).tap {|x| add_last_hash_ellipsis = x.length > config_proxy.debug_last_hash_max_length}[0..(config_proxy.debug_last_hash_max_length)]
            printed_args << config_proxy.debug_ellipsis if add_last_hash_ellipsis
          end
        else
          printed_args << String(config_proxy.debug_last_hash_to_s_proc.call(args[0])).tap {|x| add_last_hash_ellipsis = x.length > config_proxy.debug_last_hash_max_length}[0..(config_proxy.debug_last_hash_max_length)]
          printed_args << config_proxy.debug_ellipsis if add_last_hash_ellipsis
        end
      else
        if args.length == 1 && args[0].is_a?(Hash)
          # handle double splat
          printed_args << ("**" << args.map {|x| x.inspect}.join(", ").tap {|x| add_args_ellipsis = x.length > config_proxy.debug_args_max_length})[0..(config_proxy.debug_args_max_length)]
        else
          printed_args << args.map {|x| x.inspect}.join(", ").tap {|x| add_args_ellipsis = x.length > config_proxy.debug_args_max_length}[0..(config_proxy.debug_args_max_length)]
        end
        printed_args << config_proxy.debug_ellipsis if add_args_ellipsis
      end
      "(#{printed_args})"
    end
  end
end
