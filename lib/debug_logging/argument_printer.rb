require "date"
require "time"

module DebugLogging
  module ArgumentPrinter
    def debug_benchmark_to_s(tms:)
      "completed in #{format("%f", tms.real)}s (#{format("%f", tms.total)}s CPU)"
    end

    def debug_invocation_id_to_s(args: nil, kwargs: nil, start_at: nil, config_proxy: nil)
      return "" unless (args || kwargs) && config_proxy

      if config_proxy.debug_add_invocation_id
        time = start_at ? Util.debug_time(start_at) : Time.now
        unique_id = (time.to_f.to_s % "%#-21a")[4..-4]
        invocation = " ~#{args.object_id}|#{kwargs.object_id}@#{unique_id}~"
        case config_proxy.debug_add_invocation_id
        when true
          invocation
        else
          config_proxy.debug_add_invocation_id.call(ColorizedString[invocation])
        end
      else
        ""
      end
    end

    # @return [String]
    def debug_time_to_s(time_or_monotonic, config_proxy: nil)
      return "" unless config_proxy&.debug_add_timestamp
      return config_proxy.debug_time_formatter_proc.call(Time.now) unless time_or_monotonic

      time = Util.debug_time(time_or_monotonic)

      config_proxy.debug_time_formatter_proc.call(time)
    end

    # A custom time format will never apply here, because ActiveSupport::Notifications have a required time format
    def debug_event_time_to_s(time_or_monotonic)
      # Time format must match:
      #   \d{4,}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [-+]\d{4}
      #   YYYY-MM-DD HH:mm:ss +00:00
      #   strftime("%F %T %z")
      time_or_monotonic = Time.now if time_or_monotonic.nil? || (time_or_monotonic.respond_to?(:empty?) && time_or_monotonic.empty?)
      time = Util.debug_time(time_or_monotonic)
      DebugLogging::Constants::EVENT_TIME_FORMATTER.call(time)
    end

    def debug_invocation_to_s(klass: nil, separator: nil, method_to_log: nil, config_proxy: nil)
      return "" unless config_proxy

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

    def debug_signature_to_s(args: nil, kwargs: nil, config_proxy: nil) # rubocop:disable Metrics/CyclomaticComplexity
      return "" unless (args || kwargs) && config_proxy

      printed_args = ""

      add_args_ellipsis = false
      args = args.dup
      args.push(kwargs) if kwargs
      if config_proxy.debug_last_hash_to_s_proc && args[-1].is_a?(Hash)
        add_other_args_ellipsis = false
        if args.length > 1
          if config_proxy.debug_multiple_last_hashes
            last_hash_args, other_args = args.partition do |arg|
              arg.is_a?(Hash)
            end
            other_args_string = if config_proxy.debug_args_to_s_proc
              printed, add_other_args_ellipsis = debug_safe_proc(
                proc_name: "args_to_s_proc",
                proc: config_proxy.debug_args_to_s_proc,
                args: other_args,
                max_length: config_proxy.debug_args_max_length,
              )
              printed
            else
              other_args.map(&:inspect).join(", ").tap do |x|
                add_other_args_ellipsis = x.length > config_proxy.debug_args_max_length
              end[0..(config_proxy.debug_args_max_length)]
            end
            other_args_string += config_proxy.debug_ellipsis if add_other_args_ellipsis
            # On the debug_multiple_last_hashes truthy branch we don't print the ellipsis after regular args
            #   because it will go instead after each of the last hashes (if needed)
            #   ...join(", ").tap {|x| _add_args_ellipsis = x.length > config_proxy.debug_args_max_length}
            last_hash_args_string = last_hash_args.map do |arg|
              arr = []
              printed, add_last_hash_ellipsis = debug_safe_proc(
                proc_name: "last_hash_to_s_proc",
                proc: config_proxy.debug_last_hash_to_s_proc,
                args: arg,
                max_length: config_proxy.debug_last_hash_max_length,
              )
              printed += config_proxy.debug_ellipsis if add_last_hash_ellipsis
              arr << printed
              arr
            end.flatten.join(", ")
            printed_args += other_args_string if other_args_string
            printed_args += ", " if !other_args_string.empty? && !last_hash_args_string.empty?
            printed_args += last_hash_args_string if last_hash_args_string && !last_hash_args_string.empty?
          else
            other_args = args[0..-2]
            other_args_string = if config_proxy.debug_args_to_s_proc
              printed, add_other_args_ellipsis = debug_safe_proc(
                proc_name: "args_to_s_proc",
                proc: config_proxy.debug_args_to_s_proc,
                args: other_args,
                max_length: config_proxy.debug_args_max_length,
              )
              printed
            else
              other_args.map(&:inspect).join(", ").tap do |x|
                add_other_args_ellipsis = x.length > config_proxy.debug_args_max_length
              end[0..(config_proxy.debug_args_max_length)]
            end
            other_args_string += config_proxy.debug_ellipsis if add_other_args_ellipsis
            printed_args += other_args_string
            printed, add_last_hash_ellipsis = debug_safe_proc(
              proc_name: "last_hash_to_s_proc",
              proc: config_proxy.debug_last_hash_to_s_proc,
              args: args[-1],
              max_length: config_proxy.debug_last_hash_max_length,
            )
            printed_args += ", #{printed}"
            printed_args += config_proxy.debug_ellipsis if add_last_hash_ellipsis
          end
        else
          printed, add_last_hash_ellipsis = debug_safe_proc(
            proc_name: "last_hash_to_s_proc",
            proc: config_proxy.debug_last_hash_to_s_proc,
            args: args[0],
            max_length: config_proxy.debug_last_hash_max_length,
          )
          printed_args += printed
          printed_args += config_proxy.debug_ellipsis if add_last_hash_ellipsis
        end
      else
        printed_args += if config_proxy.debug_args_to_s_proc
          printed, add_args_ellipsis = debug_safe_proc(
            proc_name: "args_to_s_proc",
            proc: config_proxy.debug_args_to_s_proc,
            args: args,
            max_length: config_proxy.debug_args_max_length,
          )
          printed
        elsif args.length == 1 && args[0].is_a?(Hash)
          # handle double splat
          "**#{args.map(&:inspect).join(", ").tap do |x|
                 add_args_ellipsis = x.length > config_proxy.debug_args_max_length
               end }"[0..(config_proxy.debug_args_max_length)]
        else
          args.map(&:inspect).join(", ").tap do |x|
            add_args_ellipsis = x.length > config_proxy.debug_args_max_length
          end[0..(config_proxy.debug_args_max_length)]
        end
        printed_args += config_proxy.debug_ellipsis if add_args_ellipsis
      end
      "(#{printed_args})"
    end

    def debug_safe_proc(proc_name:, proc:, args:, max_length:)
      max_length ||= 1000 # can't be nil
      begin
        add_ellipsis = false
        printed = String(proc.call(args)).tap do |x|
          add_ellipsis = x.length > max_length
        end[0..max_length]
        [printed, add_ellipsis]
      rescue StandardError => e
        ["#{e.class}: #{e.message}\nPlease check that your #{proc_name} is able to handle #{args}", false]
      end
    end

    def debug_payload_to_s(payload: nil, config_proxy: nil)
      return "" unless payload && config_proxy

      case config_proxy.debug_add_payload
      when true
        payload.inspect
      else
        printed_payload = ""
        printed, add_payload_ellipsis = debug_safe_proc(
          proc_name: "add_payload",
          proc: config_proxy.debug_add_payload,
          args: payload,
          max_length: config_proxy.debug_payload_max_length,
        )
        printed_payload += printed
        printed_payload += config_proxy.debug_ellipsis if add_payload_ellipsis
        printed_payload
      end
    end

    module_function

    def debug_event_name_to_s(method_to_notify: nil)
      "#{method_to_notify}.log"
    end
  end
end
