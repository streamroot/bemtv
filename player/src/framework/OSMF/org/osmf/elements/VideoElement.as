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
package org.osmf.elements
{
	import __AS3__.vec.Vector;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.net.NetLoader;
	import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
	import org.osmf.traits.LoaderBase;

	CONFIG::FLASH_10_1
	{
	import flash.events.DRMAuthenticateEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.DRMStatusEvent;
	import flash.net.drm.DRMContentData;	
	import flash.system.SystemUpdaterType;
	import flash.system.SystemUpdater;	
	import org.osmf.net.drm.NetStreamDRMTrait;
	import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;
	}
	
	/**
	* VideoElement is a media element specifically created for video playback.
	* It supports streaming and progressive formats, as well as HTTP streaming
	* and MBR streaming (for both RTMP and HTTP).
	* 
	* <p>VideoElement is a more full-featured alternative to LightweightVideoElement.
	* Whereas LightweightVideoElement supports only a subset of video delivery modes
	* (specifically progressive and simple RTMP streaming), VideoElement supports
	* all video delivery modes.</p>
	*    
	* <p>The VideoElement uses a NetLoader class to load and unload its media.
	* Developers requiring custom loading logic for video
	* can pass their own loaders to the LightweightVideoElement constructor. 
	* These loaders should subclass NetLoader.</p>
	* <p>The basic steps for creating and using a LightweightVideoElement are:
	* <ol>
	* <li>Create a new URLResource pointing to the URL of the video stream or file
	* containing the video to be loaded.</li>
	* <li>Create a new NetLoader.</li>
	* <li>Create the new VideoElement, 
	* passing the NetLoader and URLResource
	* as parameters.</li>
	* <li>Create a new MediaPlayer.</li>
	* <li>Assign the VideoElement to the MediaPlayer's <code>media</code> property.</li>
	* <li>Control the media using the MediaPlayer's methods, properties, and events.</li>
	* <li>When done with the VideoElement, set the MediaPlayer's <code>media</code>  
	* property to null.  This will unload the VideoElement.</li>
	* </ol>
	* </p>
	*
	* <p>The VideoElement supports Flash Media Token Authentication,  
	* for passing authentication tokens through the NetConnection.</p>
	*
	* <p>The VideoElement has support for the Flash Player's DRM implementation.
	* Note that the <code>startDate</code>, <code>endDate</code>, and <code>period</code>
	* properties of the DRMTrait on this element correspond to the voucher validity before
	* playback starts.  Once playback begins, these properties correspond to the playback
	* time window (as found on flash.net.drm.DRMVoucher). </p>
	* 
	* @includeExample VideoElementExample.as -noswf
	* 
	* @see org.osmf.elements.LightweightVideoElement
	* @see org.osmf.media.URLResource
	* @see org.osmf.media.MediaElement
	* @see org.osmf.media.MediaPlayer
	* @see org.osmf.net.NetLoader
	* @see flash.net.drm.DRMVoucher
	* 
	*  @langversion 3.0
	*  @playerversion Flash 10
	*  @playerversion AIR 1.5
	*  @productversion OSMF 1.0
	*/
	public class VideoElement extends LightweightVideoElement
	{
		/**
		 * Constructor.
		 * 
		 * @param resource URLResource that points to the video source that the VideoElement
		 * will use.  For dynamic streaming content, use a DynamicStreamingResource.
		 * @param loader NetLoader used to load the video.  If null, the appropriate NetLoader
		 * will be created based on the resource type.
		 * 
		 * @throws ArgumentError If resource is not an URLResource. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function VideoElement(resource:MediaResourceBase=null, loader:NetLoader=null)
		{
			// Ensure that the base class doesn't create its own Loader
			// (by passing in null, then overwriting the created loader
			// with ours (or null)).
			super(null, null);
			super.loader = loader;
			
			this.resource = resource;
		}
		
		/**
		 * @private
		 **/
		override public function set resource(value:MediaResourceBase):void
		{
			// Make sure the appropriate loader is set up front.
			loader = getLoaderForResource(value, alternateLoaders);
			
			super.resource = value;
		}
		
		// Internals
		//
		
		private function get alternateLoaders():Vector.<LoaderBase>
		{
			if (_alternateLoaders == null)
			{
				_alternateLoaders = new Vector.<LoaderBase>()
			
				// Order matters.
				CONFIG::FLASH_10_1
				{
					_alternateLoaders.push(new HTTPStreamingNetLoader());
				}
				_alternateLoaders.push(new RTMPDynamicStreamingNetLoader());
				_alternateLoaders.push(new NetLoader());
			}

			return _alternateLoaders;
		}
		
		private var _alternateLoaders:Vector.<LoaderBase>;
	}
}
