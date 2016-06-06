# Copyright (C) 2011 Helicon Tech, http://www.helicontech.com

require 'optparse'
require 'fileutils'
require 'socket'
require 'stringio'
require 'Win32API'

require 'rubygems'


module ZooRack
  ROOT = File.expand_path( File.dirname( __FILE__ ) ).freeze
  LIB_PATH = File.join( ROOT, 'lib' ).freeze

  require "#{LIB_PATH}/debug"
  require "#{LIB_PATH}/const"
  require "#{LIB_PATH}/request"
  require "#{LIB_PATH}/record"
  require "#{LIB_PATH}/worker"
  require "#{LIB_PATH}/app"

  # This only works on my machine, folks ;-)
  #require "#{ROOT}/test/benchmark/bm.rb"

  # Sometimes we need to see if worker has been started at all.
  __debug__ '*** ZooRack ***'

  begin
    Worker.new.run
  rescue Object => e
    __error__ e
  end
end