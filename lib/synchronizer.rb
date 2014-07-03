# encoding: UTF-8

module Synchronizer
  include ActiveSupport::Configurable

  config.import_types ||= []
end

require "synchronizer/engine"
require "synchronizer/base"
require "synchronizer/version"

