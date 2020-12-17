module DebugLogging
  module Util
    # methods_to_log may be an array of a single method name, followed by config options and payload,
    #   or it could be an array of method names followed by config options and payload to be shared by the whole set.
    def extract_payload_and_config(method_names:, payload: nil, config: nil)
      # When scoped config is present it will always be a new configuration instance per method
      # When scoped config is not present it will reuse the class' configuration object
      scoped_payload = (method_names.is_a?(Array) && method_names.last.is_a?(Hash) && method_names.pop.clone(freeze: false)) || {}
      if payload
        payload = payload.merge(scoped_payload)
      else
        payload = scoped_payload
      end
      config_opts = config&.clone(freeze: false) || {}
      unless payload.empty?
        DebugLogging::Configuration::CONFIG_KEYS.each { |k| config_opts[k] = payload.delete(k) if payload.key?(k) }
      end
      method_names =
        case method_names
        when Symbol
          method_names
        when String
          method_names.to_sym
        when Array
          if method_names.first.is_a?(Array)
            # Array of arrays?
            method_names.shift
          elsif method_names.size == 1 && method_names.first.is_a?(Symbol)
            # when set as i_methods: [[:i_with_dsplat_payload, { tags: %w[blue green] }], ...]
            method_names.shift.to_sym
          else
            # Or an array of method name symbols?
            # logged :meth1, :meth2, :meth3 without options is valid
            method_names
          end
        end
      [method_names, payload, config_opts]
    end
    module_function :extract_payload_and_config

    def payload_instance_vaiable_hydration(scope:, payload:)
      paydirt = {}
      # TODO: Could make instance variable introspection configurable before or after method execution
      if payload.key?(:instance_variables)
        paydirt.merge!(payload.reject { |k| k == :instance_variables })
        payload[:instance_variables].each do |k|
          paydirt[k] = scope.send(:instance_variable_get, "@#{k}") if scope.send(:instance_variable_defined?, "@#{k}")
        end
      else
        paydirt.merge!(payload)
      end
      paydirt
    end
    module_function :payload_instance_vaiable_hydration

    def config_proxy_finder(scope:, config_opts: {}, method_name:, proxy_ref:, &block)
      if (proxy = scope.send(:instance_variable_get, DebugLogging::Configuration.config_pointer(proxy_ref,
                                                                                   method_name)))
        proxy
      else
        base = scope.respond_to?(:debug_config) ? scope.debug_config : DebugLogging.debug_logging_configuration
        proxy = if config_opts.empty?
                  base
                else
                  DebugLogging::Configuration.new(**base.to_hash.merge(config_opts))
                end
        proxy.register(method_name)
        scope.send(:instance_variable_set, DebugLogging::Configuration.config_pointer(proxy_ref, method_name),
                              proxy)
        yield proxy if block
        proxy
      end
    end
    module_function :config_proxy_finder
  end
end