source 'http://rubygems.org'

# Specify your gem's dependencies in guard-passenger.gemspec
gemspec

gem 'rake'
require 'rbconfig'

if Config::CONFIG['target_os'] =~ /darwin/i
  gem 'rb-fsevent', '>= 0.3.2'
  gem 'growl', '~> 1.0.3'
elsif Config::CONFIG['target_os'] =~ /linux/i
  gem 'rb-inotify', '>= 0.5.1'
  gem 'libnotify', '~> 0.1.3'
end