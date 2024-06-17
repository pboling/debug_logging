source "https://rubygems.org"

#### IMPORTANT #######################################################
# Gemfile is for local development ONLY; Gemfile is NOT loaded in CI #
####################################################### IMPORTANT ####

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in debug_logging.gemspec
gemspec

platform :mri do
  # Debugging
  gem "byebug", ">= 11"
end
