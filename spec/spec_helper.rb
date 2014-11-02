# require 'coveralls'
# Coveralls.wear!

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

#grr-can't make this work quickly
Dir.glob("spec/dummy/spec/factories/*.rb").each do |file|
  puts "loading #{file}"
   load "#{file}"
end
Rails.backtrace_cleaner.remove_silencers!


