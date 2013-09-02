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
package org.osmf.elements.audioClasses
{
	import flash.events.Event;
	
	import org.osmf.media.MediaElement;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.PlayState;
			
	[ExcludeClass]
	
	/**
	 * @private
	 **/
	public class AudioPlayTrait extends PlayTrait
	{
		public function AudioPlayTrait(soundAdapter:SoundAdapter)
		{
			super();
			
			this.soundAdapter = soundAdapter;

			// Note that we add the listener with a high priority. The reason
			// for this is that we want to process the COMPLETE event before
			// the AudioTimeTrait processes it and dispatches its own COMPLETE
			// event.  Clients who register for the COMPLETE event will expect
			// that the media is no longer playing.
			soundAdapter.addEventListener(Event.COMPLETE, onPlaybackComplete, false, 1, true);				
		}
		
		override protected function playStateChangeStart(newPlayState:String):void
		{	
			if (newPlayState == PlayState.PLAYING)
			{
				lastPlayFailed = !soundAdapter.play();			
			}
			else if (newPlayState == PlayState.PAUSED)
			{
				soundAdapter.pause();
			}				
			else if (newPlayState == PlayState.STOPPED)
			{
				soundAdapter.stop();
			}				
		}

		override protected function playStateChangeEnd():void
		{
			if (lastPlayFailed)
			{
				stop();
				
				lastPlayFailed = false;
			}
			else
			{
				super.playStateChangeEnd();
			}
		}
		
		private function onPlaybackComplete(event:Event):void
		{
			stop();
		}

		private var lastPlayFailed:Boolean = false;					
		private var soundAdapter:SoundAdapter;			
	}
}