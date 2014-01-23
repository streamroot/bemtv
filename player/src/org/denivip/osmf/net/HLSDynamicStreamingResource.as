package org.denivip.osmf.net
{
	import org.osmf.net.DynamicStreamingResource;
	
	/**
	 * Simple DynamicStreamingResource, used for correct quality switching
	 */
	public class HLSDynamicStreamingResource extends DynamicStreamingResource
	{
		public function HLSDynamicStreamingResource(
			url:String,
			streamType:String = null
		)
		{
			super(url, streamType);
		}
		
		override public function indexFromName(name:String):int{
			var index:int = 0;
			
			while(index < streamItems.length){
				if(streamItems[index].streamName == name)
					return index;
				
				index++;
			}
			
			return -1;
		}
	}
}