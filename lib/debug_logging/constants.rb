module DebugLogging
  module Constants
    DEFAULT_ELLIPSIS = " ✂️ …"
    DEFAULT_TIME_FORMATTER = ->(time) { "[#{time.strftime("%Y%m%d %H:%M:%S")}] " }
    EVENT_TIME_FORMATTER = ->(time) { time.strftime("%F %T %z") }
    CONFIG_ATTRS_DEFAULTS = {
      enabled: true,
      logger: Logger.new($stdout), # probably want to override to be the Rails.logger
      log_level: :debug, # at what level do the messages created by this gem sent at?
      multiple_last_hashes: false,
      last_hash_to_s_proc: nil, # e.g. ->(hash) { "keys: #{hash.keys}" }
      last_hash_max_length: 1_000,
      args_to_s_proc: nil, # e.g. ->(*record) { "record id: #{record.first.id}" }
      args_max_length: 1_000,
      colorized_chain_for_method: false, # e.g. ->(colorized_string) { colorized_string.red.on_blue.underline }
      colorized_chain_for_class: false,  # e.g. ->(colorized_string) { colorized_string.colorize(:light_blue ).colorize( :background => :red) }
      add_invocation_id: true, # allows unique identification of method call; association of entry and exit log lines
      ellipsis: DEFAULT_ELLIPSIS,
      mark_scope_exit: false,
      add_payload: true, # Can also be a proc returning a string, which will be called when printing the payload
      payload_max_length: 1_000,
      error_handler_proc: nil,
      time_formatter_proc: DEFAULT_TIME_FORMATTER,
      add_timestamp: false,
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
