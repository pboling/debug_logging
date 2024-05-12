# Std Lib
require "rational"

# This does not require "simplecov",
#   because that has a side-effect of running `.simplecov`
require "kettle-soup-cover"

# RSpec Configs
require "config/byebug"
require "config/rspec/rspec_block_is_expected"
require "config/rspec/rspec_core"
require "config/rspec/silent_stream"
require "config/rspec/version_gem"
require "config/rspec/helpers"

# Last thing before this gem is code coverage:
require "simplecov" if Kettle::Soup::Cover::DO_COV

# This gem!
require "debug_logging"
require "support/shared_context"
