package org.denivip.osmf.net
{
	import org.osmf.net.DynamicStreamingItem;
	
	/**
	 * HLS Stream complex item
	 * Contains stream chunks
	 * Generated from #EXT-X-STREAM-INF tag (if multiquality playlist), or whole playlist (if simple)
	 */
	public class HLSDynamicStreamingItem extends DynamicStreamingItem
	{
		public function HLSDynamicStreamingItem(streamName:String,
												bitrate:Number,
												sequenceNumber:Number=0.,
												width:int=-1,
												height:int=-1)
		{
			super(streamName, bitrate, width, height);
		}
	}
}