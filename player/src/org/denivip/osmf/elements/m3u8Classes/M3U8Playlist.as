package org.denivip.osmf.elements.m3u8Classes
{
	import org.osmf.net.httpstreaming.dvr.DVRInfo;

	/**
	 * Parsed playlist element
	 */
	public class M3U8Playlist extends M3U8Item
	{
		public var sequenceNumber:int;
		
		public var isLive:Boolean = true;
		
		public var streamItems:Vector.<M3U8Item>;
		
		public var dvrInfo:DVRInfo;
		
		public function get totalLength():int{
			if(streamItems[0] is M3U8Playlist)
				return M3U8Playlist(streamItems[0]).totalLength;
			else
				return streamItems.length;
		}
		
		override public function get duration():Number{
			if(streamItems[0] is M3U8Playlist)
				return M3U8Playlist(streamItems[0]).duration;
			else
				return _duration;
		}
		
		public function M3U8Playlist(duration:Number, url:String){
			super(duration, url);
			
			streamItems = new Vector.<M3U8Item>();
			_startTime = 0;
		}
		
		public function addItem(item:M3U8Item):void{
			if(!(item is M3U8Playlist)){
				item.startTime = _duration;
				_duration += item.duration;
			}
			streamItems.push(item);
		}
	}
}