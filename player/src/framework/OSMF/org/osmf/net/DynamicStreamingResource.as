/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved.
* 
*  Contributor: Adobe Systems Inc.
*  
*****************************************************/
package org.osmf.net
{
	import __AS3__.vec.Vector;
	
	import org.osmf.utils.OSMFStrings;

	/**
	 * DynamicStreamingResource encapsulates multiple representations of a
	 * piece of media, such that the player application can dynamically
	 * switch from one representation to another.  Typically (though not
	 * always), each representation is encoded at a different bitrate,
	 * and the player application switches between representations based
	 * on changes to the client's available bandwidth.
	 * 
	 * <p>This class provides an object representation of a dynamic streaming
	 * resource without any knowledge or assumption of any file format, 
	 * such as SMIL, Media RSS, F4M, etc.</p>
	 * 
	 * @includeExample DynamicStreamingResourceExample.as -noswf
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class DynamicStreamingResource extends StreamingURLResource
	{
		/**
		 * Constructor.
		 * 
		 * @param host A URL representing the host of the dynamic streaming resource.
		 * @param streamType The type of the stream.  If null, defaults to StreamType.RECORDED.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function DynamicStreamingResource(host:String, streamType:String=null)
		{
			super(host, streamType);
			
			_initialIndex = 0;
		}
		
		/**
		 * A URL representing the host of the dynamic streaming resource.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get host():String
		{
			return url;
		}
				
		/**
		 * Vector of DynamicStreamingItems.  Each item represents a
		 * different bitrate stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get streamItems():Vector.<DynamicStreamingItem>
		{
			if (_streamItems == null)
			{
				_streamItems = new Vector.<DynamicStreamingItem>();
			}
			
			return _streamItems;
		}
		
		public function set streamItems(value:Vector.<DynamicStreamingItem>):void
		{
			_streamItems = value;
			
			if (value != null)
			{
				value.sort(compareStreamItems);
			}
		}
		
		/**
		 * The preferred starting index.
		 * 
		 * @throws RangeError If the index is out of range.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get initialIndex():int
		{
			return _initialIndex;
		}
		
		public function set initialIndex(value:int):void
		{
			if (_streamItems == null || value >= _streamItems.length)
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));				
			}
			
			_initialIndex = value;
		}
    			
		// Internals
		//		
    					
		/**
		 * @private
		 * 
		 * Returns the index associated with a stream name. The match will be tried 
		 * both with and without a mp4: prefix. Returns -1 if no match is found.
		 */		
		internal function indexFromName(name:String):int 
		{
			for (var i:int = 0; i < _streamItems.length; i++) 
			{
				// FM-925, stream name may be appended with parameters.
				if (_streamItems[i].streamName.indexOf(name) == 0 ||
					_streamItems[i].streamName.indexOf("mp4:" + name) == 0)  
				{
					return i;
				}
			}
			return -1;
		}
		
		/**
		 * A comparison method that determines the behavior of the sort of the vector member variable.
		 * Given two elements a and b, the function returns one of the following three values:
		 * <ol>
	     * <li>a negative number, if a should appear before b in the sorted sequence</li>
    	 * <li>0, if a equals b</li>
    	 * <li>a positive number, if a should appear after b in the sorted sequence</li>
    	 * </ol>
    	 *  
    	 *  @langversion 3.0
    	 *  @playerversion Flash 10
    	 *  @playerversion AIR 1.5
    	 *  @productversion OSMF 1.0
    	 */
		private function compareStreamItems(a:DynamicStreamingItem, b:DynamicStreamingItem):Number
		{
			var result:Number = -1;
			
			if (a.bitrate == b.bitrate)
			{
				result = 0;
			}
			else if (a.bitrate > b.bitrate)
			{
				result = 1;
			}
			
			return result;
		}

		private var _streamItems:Vector.<DynamicStreamingItem>;
		private var _initialIndex:int;
	}
}
