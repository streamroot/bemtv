require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'rake/clean'
require 'flashsdk'

Bundler.require :default
#FlashSDK::MXMLC.add_param :swf_version, String

def configure_task t
  t.target_player             = "11.1"
  t.optimize                  = true
  t.incremental               = true
  t.strict                    = true
  t.language                  = 'as3'
  t.use_network               = false
  t.source_path            << 'src/'
  t.library_path           << 'lib/as3crypto.swc'
  t.library_path           << 'lib/blooddy_crypto.swc'
  t.static_link_runtime_shared_libraries = true
  t.default_size = '480,270'
  t.default_background_color = "0x000000"
end

task :default => "P2PPlayer.swf"

mxmlc "P2PPlayer.swf" do |t|
  t.input = "src/org/mangui/chromeless/ChromelessPlayer.as"
  t.output = "../globocom-player/src/plugins/bemtv_playback/public/P2PPlayer.swf"
  configure_task t
end

task :build_swf => "HLSPlayer.swf"

task :build_all => [:build_swf]

