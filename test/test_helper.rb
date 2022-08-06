# -*- encoding: utf-8 -*-

begin
  require 'simplecov'
  SimpleCov.start do
    minimum_coverage line: 100
    add_filter '/test/'
  end
rescue LoadError
  puts "No code coverage because simplecov is not installed"
end

gem 'minitest'
require 'minitest/autorun'
require 'hexapdf/test_utils'

Minitest::Test.make_my_diffs_pretty!
