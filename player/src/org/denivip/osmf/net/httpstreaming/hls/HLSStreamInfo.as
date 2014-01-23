package org.denivip.osmf.net.httpstreaming.hls
{
	public class HLSStreamInfo
	{
		private var _streamName:String;
		private var _bitrate:Number;
		
		public function HLSStreamInfo(
			streamName:String,
			bitrate:Number
		){
			_streamName = streamName;
			_bitrate = bitrate;
		}
		
		public function get streamName():String{ return _streamName; }
		public function get bitrate():Number{ return _bitrate; }
	}
}