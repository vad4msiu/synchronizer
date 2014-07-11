# encoding: UTF-8

module Synchronizer
  include ActiveSupport::Configurable

  config.local_types ||= []
  config.import_class_name ||= 'Synchronizer::ImportRecord'
end

require "synchronizer/engine"
require "synchronizer/base"
require "synchronizer/version"

