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
	import flash.events.ProgressEvent;
	
	import org.osmf.traits.TimeTrait;
	
	[ExcludeClass]
	
	/**
	 * @private
	 **/
	public class AudioTimeTrait extends TimeTrait
	{
		public function AudioTimeTrait(soundAdapter:SoundAdapter)
		{
			super();
			
			this.soundAdapter = soundAdapter;
			
			// The sound object's length changes as the file downloads.
			// We update the duration accordingly with ever more accurate estimates.
			soundAdapter.addEventListener(ProgressEvent.PROGRESS, onDownloadProgress, false, 0, true);	
			soundAdapter.addEventListener(SoundAdapter.DOWNLOAD_COMPLETE, onDownloadComplete, false, 0, true);
			soundAdapter.addEventListener(Event.COMPLETE, onPlaybackComplete, false, 0, true);	
		}
		
		override public function get currentTime():Number
		{
			return soundAdapter.currentTime;
		}		
		
		// Internals
		//
		
		private function onDownloadProgress(event:Event):void
		{		
			// Take the first good update, and wait until the download finishes.
			if (!isNaN(soundAdapter.estimatedDuration) &&
				soundAdapter.estimatedDuration > 0) 
			{
				soundAdapter.removeEventListener(ProgressEvent.PROGRESS, onDownloadProgress);				
				setDuration(soundAdapter.estimatedDuration);
			}
		}

		private function onDownloadComplete(event:Event):void
		{				
			setDuration(soundAdapter.estimatedDuration);
		}
		
		private function onPlaybackComplete(event:Event):void
		{
			signalComplete();
		}
		
		private var soundAdapter:SoundAdapter;
	}
}