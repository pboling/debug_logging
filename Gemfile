source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :test do
  ruby_version = Gem::Version.new(RUBY_VERSION)
  if ruby_version >= Gem::Version.new('2.1')
    gem 'rubocop', '~> 0.63.0'
    gem 'rubocop-rspec', '~> 1.30.0'
  end
  if ruby_version >= Gem::Version.new('2.0')
    gem 'byebug', '~> 10', platform: :mri, require: false
    gem 'pry', '~> 0', platform: :mri, require: false
    gem 'pry-byebug', '~> 3', platform: :mri, require: false
  end
  # NOTE: Switching coveralls to simplecov causing many spec failures.
  #       Something about coveralls bleeds into this gem, and this gem is
  #       dependent on that tweaking behavior
  gem 'coveralls', '~> 0', require: false
end

# Specify your gem's dependencies in debug_logging.gemspec
gemspec
