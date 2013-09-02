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
	import org.osmf.events.BeaconEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	[ExcludeClass]
	
	/**
	 * @private
	 **/
	public class BeaconPlayTrait extends PlayTrait
	{
		public function BeaconPlayTrait(beacon:Beacon)
		{
			super();
			
			this.beacon = beacon;
		}

		override public function get canPause():Boolean
		{
			return false;
		}
		
		override protected function playStateChangeStart(newPlayState:String):void
		{
			if (newPlayState == PlayState.PLAYING)
			{
				// A play equals a "ping".
				beacon.addEventListener(BeaconEvent.PING_COMPLETE, onBeaconEvent);
				beacon.addEventListener(BeaconEvent.PING_ERROR, onBeaconEvent);
				beacon.ping();
				
				function onBeaconEvent(event:BeaconEvent):void
				{
					beacon.removeEventListener(BeaconEvent.PING_COMPLETE, onBeaconEvent);
					beacon.removeEventListener(BeaconEvent.PING_ERROR, onBeaconEvent);
					
					if (event.type == BeaconEvent.PING_ERROR)
					{
						dispatchEvent
							( new MediaErrorEvent
								( MediaErrorEvent.MEDIA_ERROR
								, false
								, false
								, new MediaError(MediaErrorCodes.HTTP_GET_FAILED, event.errorText)
								)
							);
					}
				}

			}
		}
		
		override protected function playStateChangeEnd():void
		{
			super.playStateChangeEnd();
			
			if (playState == PlayState.PLAYING)
			{
				// When the play() is finished, we reset our state to "not playing",
				// since this trait has completed its work.
				stop();
			}
		}

		private var beacon:Beacon;
	}
}