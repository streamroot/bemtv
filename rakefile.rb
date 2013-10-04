require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'rake/clean'
require 'flashsdk'

Bundler.require :default

require File.expand_path('tasks/helpers', File.dirname(__FILE__))
Dir['tasks/**/*.rake'].each { |file| load file }

##
# Set USE_FCSH to true in order to use FCSH for all compile tasks.
#
# You can also set this value by calling the :fcsh task
# manually like:
#
#   rake fcsh run
#
# These values can also be sent from the command line like:
#
#   rake run FCSH_PKG_NAME=flex3
#
# ENV['USE_FCSH']         = true
# ENV['FCSH_PKG_NAME']    = 'flex4'
# ENV['FCSH_PKG_VERSION'] = '1.0.14.pre'
# ENV['FCSH_PORT']        = 12321

FlashSDK::MXMLC.add_param :swf_version, String

def configure_task t
  t.target_player           = "11.1.0"
  t.swf_version             = "11"
  t.language                = 'as3'
  t.optimize                = true
  t.strict                  = true
  t.library_path << 'player/lib/OSMF.swc'
  t.library_path << 'player/assets'
  t.static_link_runtime_shared_libraries = true
  t.define_conditional                    << "CONFIG::LOGGING,false"
  t.define_conditional                    << "CONFIG::FLASH_10_1,true"
  t.define_conditional                    << "CONFIG::PLATFORM,true"
  t.define_conditional                    << "CONFIG::MOCK,false"
  t.default_size = '480,360'
end

##############################
# Debug

# Compile the debug swf
mxmlc "player/bin/StrobeMediaPlayback-debug.swf" => 'assets:copy' do |t|
  t.input = "player/src/StrobeMediaPlayback.as"
  t.debug = true
  configure_task t
end

desc "Compile debug swf"
task :compile_debug => "player/bin/StrobeMediaPlayback-debug.swf"

task :debug => [:compile_debug, 'assets:rename_debug_swf']

desc "Compile and run the debug swf"
flashplayer :run => "player/bin/StrobeMediaPlayback-debug.swf"

##############################
# DOC

desc "Generate documentation at doc/"
asdoc 'doc' do |t|
  t.doc_sources << "src"
  t.exclude_sources << "player/src/StrobeMediaPlaybackRunner.as"
end

mxmlc "html/static/StrobeMediaPlayback.swf" do |t|
  t.input = "player/src/StrobeMediaPlayback.as"
  configure_task t
end

desc 'Compile the optimized deployment'
task :compile => "html/static/StrobeMediaPlayback.swf"

##############################
# DEFAULT
task :default => :debug

