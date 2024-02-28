module DebugLogging
  module Constants
    DEFAULT_ELLIPSIS = " ✂️ …"
    CONFIG_ATTRS_DEFAULTS = {
      enabled: true,
      logger: Logger.new($stdout),
      log_level: :debug,
      multiple_last_hashes: false,
      last_hash_to_s_proc: nil,
      last_hash_max_length: 1_000,
      args_to_s_proc: nil,
      args_max_length: 1_000,
      colorized_chain_for_method: false,
      colorized_chain_for_class: false,
      add_invocation_id: true,
      ellipsis: DEFAULT_ELLIPSIS,
      mark_scope_exit: false,
      add_payload: true, # Can also be a proc returning a string, which will be called when printing the payload
      payload_max_length: 1_000,
      error_handler_proc: nil,
    }.freeze
    CONFIG_ATTRS = CONFIG_ATTRS_DEFAULTS.keys
    CONFIG_READERS_DEFAULTS = {
      instance_benchmarks: false,
      class_benchmarks: false,
      active_support_notifications: false,
    }.freeze
    CONFIG_READERS = CONFIG_READERS_DEFAULTS.keys
    CONFIG_KEYS = CONFIG_ATTRS + CONFIG_READERS
  end
end
