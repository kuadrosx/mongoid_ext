require 'simplecov'

module SimpleCov
  module Configuration
    def clean_filters
      @filters = []
    end
  end
end

SimpleCov.configure do
  clean_filters
  load_profile 'test_frameworks'
end

ENV["COVERAGE"] && SimpleCov.start do
  add_filter "/.rvm/"
end
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require "minitest/autorun"
require 'minitest/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongoid_ext'

if MONGOID5
  Mongoid.load!("test/mongoid.yml", "test")
else
  Mongoid.load!("test/mongoid4.yml", "test")
end

Mongo::Logger.logger.level = Logger::WARN if MONGOID5

require 'models'

class MiniTest::Unit::TestCase
end

Minitest.autorun
