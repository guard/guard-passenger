require 'rubygems'
require 'guard/passenger'
require 'rspec'
require 'rspec/mocks'

ENV["GUARD_ENV"] = 'test'

Dir["#{File.expand_path('..', __FILE__)}/support/**/*.rb"].each { |f| require f }

puts "Please do not update/create files while tests are running."

require "guard/compat/test/helper"

RSpec.configure do |config|
  config.color_enabled = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end

# Thanks to Jonas Pfenniger for this!
# http://gist.github.com/487157
def quietly(&block)
  begin
    orig_stdout = $stdout.dup # does a dup2() internally
    $stdout.reopen('/dev/null', 'w')
    yield
  ensure
    $stdout.reopen(orig_stdout)
  end
end
