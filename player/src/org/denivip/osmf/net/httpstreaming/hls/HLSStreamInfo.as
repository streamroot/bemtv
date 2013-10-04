package org.denivip.osmf.net.httpstreaming.hls
{
	public class HLSStreamInfo
	{
		private var _streamName:String;
		private var _bitrate:Number;
		private var _metadata:Object;
		
		public function HLSStreamInfo(
			streamName:String,
			bitrate:Number,
			metadata:Object
		){
			_streamName = streamName;
			_bitrate = bitrate;
			_metadata = metadata;
		}
		
		public function get streamName():String{ return _streamName; }
		public function get bitrate():Number{ return _bitrate; }
		public function get metadata():Object{ return _metadata; }
	}
}