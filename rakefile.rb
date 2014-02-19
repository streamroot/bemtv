require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'rake/clean'
require 'flashsdk'

Bundler.require :default
#FlashSDK::MXMLC.add_param :swf_version, String

def configure_task t
  t.target_player             = "11.1"
#  t.swf_version               = "11"
  t.optimize                  = true
  t.incremental               = true
  t.use_network               = false
  t.source_path            << 'HLSprovider/src/'
  t.library_path           << 'HLSprovider/lib/as3crypto.swc'
  t.static_link_runtime_shared_libraries = true
  t.default_size = '480,270'
  t.default_background_color = "0x000000"
end

task :default => "HLSPlayer.swf"

mxmlc "HLSPlayer.swf" do |t|
  t.input = "HLSProvider/src/org/mangui/chromeless/ChromelessPlayer.as"
  t.output = "html/static/HLSPlayer.swf"
  configure_task t
end

task :build_swf => "HLSPlayer.swf"

task :build_js do
  sh "browserify -s BemTV -r ./src/BemTV.js > ./html/js/bemtv.bundle.js"
end

task :install_js_deps do
  sh "npm install -g browserify"
  sh "cd src;npm install rtc-quickconnect rtc-bufferedchannel freeice;cd .."
end

task :build_all => [:install_js_deps, :build_js, :build_swf]

