/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.elements.beaconClasses
{
	import flash.events.EventDispatcher;
	
	import org.osmf.events.BeaconEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoadState;
	import org.osmf.utils.HTTPLoader;
	import org.osmf.utils.HTTPLoadTrait;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * Dispatched when the Beacon's HTTP request has succeeded.
	 * 
	 * @eventType org.osmf.events.BeaconEvent.PING_COMPLETE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="pingComplete",type="org.osmf.events.BeaconEvent")]

	/**
	 * Dispatched when the Beacon's HTTP request has failed.
	 * 
	 * @eventType org.osmf.events.BeaconEvent.PING_ERROR
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="pingError",type="org.osmf.events.BeaconEvent")]

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * A Beacon encapsulates an HTTP request to a resource, in which
	 * the response is irrelevant.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class Beacon extends EventDispatcher
	{
		/**
		 * Constructor.
		 * 
		 * @param url The URL of the beacon to ping.
		 * @param httpLoader The HTTPLoader to use to ping the beacon.  If
		 * null, then a default HTTPLoader will be used.
		 * 
		 * @throws ArgumentError If url is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function Beacon(url:String, httpLoader:HTTPLoader=null)
		{
			if (url == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			this.url = url;
			this.httpLoader = httpLoader != null ? httpLoader : new HTTPLoader();
		}
		
		/**
		 * Pings the URL of this beacon.  Will dispatch a BeaconEvent when
		 * the ping either succeeds or fails.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function ping():void
		{
			var urlResource:URLResource = new URLResource(url);
			
			// Make sure we can actually load the resource.  If we can't
			// we treat this as a ping failure.
			if (httpLoader.canHandleResource(urlResource))
			{
				var loadTrait:LoadTrait = new HTTPLoadTrait(httpLoader, urlResource);
				
				loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
				loadTrait.load();
	
				function onLoadStateChange(event:LoadEvent):void
				{
					if (event.loadState == LoadState.READY)
					{
						loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
						
						dispatchEvent(new BeaconEvent(BeaconEvent.PING_COMPLETE));
					}
					else if (event.loadState == LoadState.LOAD_ERROR)
					{
						loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
						
						dispatchEvent(new BeaconEvent(BeaconEvent.PING_ERROR));
					}
				}
			}
			else
			{
				dispatchEvent(new BeaconEvent(BeaconEvent.PING_ERROR));
			}
		}
		
		private var url:String;
		private var httpLoader:HTTPLoader;
	}
}