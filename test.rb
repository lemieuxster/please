#!/usr/bin/env ruby

require 'optparse'

module Tester
  class Test
    def initialize
      puts "Hi"
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: test.rb [options]"
        opts.on("-f", "--f [BOOL]", "Foo") do |f|
          options[:foo] = f
        end
      end.parse!

      p options
    end

    def run!
      puts "Running"
    end
  end
end

tester = Tester::Test.new