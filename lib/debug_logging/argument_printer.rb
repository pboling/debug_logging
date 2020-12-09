# frozen_string_literal: true

module DebugLogging
  module ArgumentPrinter
    def debug_benchmark_to_s(tms: nil)
      "completed in #{format('%f', tms.real)}s (#{format('%f', tms.total)}s CPU)"
    end

    def debug_invocation_id_to_s(args: nil, config_proxy: nil)
      return '' unless args && config_proxy

      if config_proxy.debug_add_invocation_id
        invocation = " ~#{args.object_id}@#{(Time.now.to_f.to_s % '%#-21a')[4..-4]}~"
        case config_proxy.debug_add_invocation_id
        when true
          invocation
        else
          config_proxy.debug_add_invocation_id.call(ColorizedString[invocation])
        end
      else
        ''
      end
    end

    def debug_invocation_to_s(klass: nil, separator: nil, method_to_log: nil, config_proxy: nil)
      return '' unless config_proxy
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

    def debug_signature_to_s(args: nil, config_proxy: nil) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      return '' unless args && config_proxy

      printed_args = ''

      add_args_ellipsis = false
      if config_proxy.debug_last_hash_to_s_proc && args[-1].is_a?(Hash)
        add_last_hash_ellipsis = false
        if args.length > 1
          if config_proxy.debug_multiple_last_hashes
            last_hash_args, other_args = args.partition do |arg|
              arg.is_a?(Hash)
            end
            other_args_string = other_args.map(&:inspect).join(', ')[0..(config_proxy.debug_args_max_length)]
            # On the debug_multiple_last_hashes truthy branch we don't print the ellipsis after regular args
            #   because it will go instead after the last hash (if needed)
            #   ...join(", ").tap {|x| _add_args_ellipsis = x.length > config_proxy.debug_args_max_length}
            last_hash_args_string = last_hash_args.map do |arg|
              arr = []
              arr << config_proxy.debug_last_hash_to_s_proc.call(arg).to_s
                                 .tap do |x|
                add_last_hash_ellipsis = x.length > config_proxy.debug_last_hash_max_length
              end
              if add_last_hash_ellipsis
                arr[-1] = arr[-1][0..(config_proxy.debug_last_hash_max_length)]
                arr << config_proxy.debug_ellipsis
              end
              arr
            end.flatten.join(', ')
            printed_args += other_args_string if other_args_string
            printed_args += ', ' if !other_args_string.empty? && !last_hash_args_string.empty?
            printed_args += last_hash_args_string if last_hash_args_string && !last_hash_args_string.empty?
          else
            printed_args += args[0..-2].map(&:inspect).join(', ').tap { |x| add_args_ellipsis = x.length > config_proxy.debug_args_max_length }[0..(config_proxy.debug_args_max_length)]
            printed_args += config_proxy.debug_ellipsis if add_args_ellipsis
            printed_args += ", #{config_proxy.debug_last_hash_to_s_proc.call(args[-1]).tap { |x| add_last_hash_ellipsis = x.length > config_proxy.debug_last_hash_max_length }[0..(config_proxy.debug_last_hash_max_length)]}"
            printed_args += config_proxy.debug_ellipsis if add_last_hash_ellipsis
          end
        else
          printed_args += String(config_proxy.debug_last_hash_to_s_proc.call(args[0])).tap { |x| add_last_hash_ellipsis = x.length > config_proxy.debug_last_hash_max_length }[0..(config_proxy.debug_last_hash_max_length)]
          printed_args += config_proxy.debug_ellipsis if add_last_hash_ellipsis
        end
      else
        if args.length == 1 && args[0].is_a?(Hash)
          # handle double splat
          printed_args += ("**#{args.map(&:inspect).join(', ').tap { |x| add_args_ellipsis = x.length > config_proxy.debug_args_max_length }}")[0..(config_proxy.debug_args_max_length)]
        else
          printed_args += args.map(&:inspect).join(', ').tap { |x| add_args_ellipsis = x.length > config_proxy.debug_args_max_length }[0..(config_proxy.debug_args_max_length)]
        end
        printed_args += config_proxy.debug_ellipsis if add_args_ellipsis
      end
      "(#{printed_args})"
    end

    def debug_payload_to_s(payload: nil, config_proxy: nil)
      return '' unless payload && config_proxy

      if payload
        case config_proxy.debug_add_payload
        when true
          payload.inspect
        else
          config_proxy.debug_add_payload.call(**payload)
        end
      else
        ''
      end
    end

    module_function

    def debug_event_name_to_s(method_to_notify: nil)
      "#{method_to_notify}.log"
    end
  end
end
