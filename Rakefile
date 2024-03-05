require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
desc "alias spec => test"
task test: :spec

require "rubocop/lts"
Rubocop::Lts.install_tasks

task default: %i[spec rubocop_gradual]
