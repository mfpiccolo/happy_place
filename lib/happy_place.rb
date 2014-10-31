require "happy_place/version"
require 'happy_place/railtie' if defined?(Rails)

module HappyPlace
  def self.included(base)
    super
  end
end
