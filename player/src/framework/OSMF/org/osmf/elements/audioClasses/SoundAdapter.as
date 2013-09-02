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
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaElement;
    
	[ExcludeClass]
	
	/**
	 * Dispatched when playback of the Sound completes.
	 * 
	 * @eventType flash.events.Event.COMPLETE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
    [Event(name="complete", type="flash.events.Event")]
    
	/**
	 * Dispatched when download of the Sound completes.
	 * 
	 * @eventType downloadComplete
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
    [Event(name="downloadComplete", type="flash.events.Event")]
    
	/**
	 * Dispatched periodically as the download of the Sound progresses.
	 * 
	 * @eventType flash.events.ProgressEvent.PROGRESS
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
    [Event(name="progress", type="flash.events.ProgressEvent")]
            
    /**
    * @private
    * 
    * Utility class to make working with the Sound class a bit easier.
    *  
    *  @langversion 3.0
    *  @playerversion Flash 10
    *  @playerversion AIR 1.5
    *  @productversion OSMF 1.0
    */
	public class SoundAdapter extends EventDispatcher
	{
		public static const DOWNLOAD_COMPLETE:String = "downloadComplete";	
		
		public function SoundAdapter(owner:MediaElement, sound:Sound)
		{
			super();
			
			this.owner = owner;
			this.sound = sound;
			_soundTransform = new SoundTransform();
			
			sound.addEventListener(Event.COMPLETE, onDownloadComplete, false, 0, true);
			sound.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
			sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
		}
		
		public function get currentTime():Number
		{			
			return channel != null ? channel.position / 1000 : lastStartTime / 1000;
		}

		/**
		 * Returns an estimate of the duration of the partially downloaded
		 * audio file, in seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get estimatedDuration():Number
		{
			return sound.length / (1000 * sound.bytesLoaded / sound.bytesTotal);	
		}	
		
		public function get soundTransform():SoundTransform
		{
			return _soundTransform;
		}
		
		public function set soundTransform(value:SoundTransform):void
		{
			_soundTransform = value;
			if (channel != null)
			{
				channel.soundTransform = value;	
			}		
		}

		/**
		 * Play the sound.  If the given time is -1, starts from the
		 * beginning.  Otherwise, attempts to play from that point.
		 * 
		 * @returns True if playing the file was successful, false if
		 * playback failed for some reason.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function play(time:Number=-1):Boolean
		{
			var success:Boolean = false;
			
			if (channel == null)
			{
				// HTTPS urls can throw errors here.
				try
				{
					channel = sound.play(time != -1 ? time : lastStartTime);
				}
				catch (error:ArgumentError) 
				{
					// Do nothing, just send the playback error (see below).
					channel = null;					
				}
				
				if (channel != null)
				{
					playing = true;
					
					// Apply any previously-set SoundTransform on the new channel.
					channel.soundTransform = _soundTransform;
					
					channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
					
					success = true;
				}
				else
				{
					// When channel is null, we either have no sound card or no
					// sound channels available.
					owner.dispatchEvent
						( new MediaErrorEvent
							( MediaErrorEvent.MEDIA_ERROR
							, false
							, false
							, new MediaError(MediaErrorCodes.SOUND_PLAY_FAILED)
							)
						);
				}
			}
			
			return success;
		}
					
		public function pause():void
		{
			if (channel != null)
			{
				lastStartTime = channel.position;
				
				clearChannel();
				playing = false;
			}
		}
		
		public function stop():void
		{
			if (channel != null)
			{
				lastStartTime = 0;
				
				clearChannel();
				playing = false;
			}
		}
		
		public function seek(time:Number):void
		{
			var wasPlaying:Boolean = playing;
			
			if (channel != null)
			{
				clearChannel();
			}

			play(time*1000);

			if (wasPlaying == false)
			{
				pause();
			}
		}	
						
		// Internals
		//
		
		private function clearChannel():void
		{
			if (channel != null)
			{
				channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				channel.stop();
				channel = null;
			}
		}
		
		private function onSoundComplete(event:Event):void
		{
			lastStartTime = channel.position;
			
			clearChannel();
			playing = false;
			
			// Signal playback has completed.
			dispatchEvent(new Event(Event.COMPLETE));
		}
				
		private function onDownloadComplete(event:Event):void
		{
			dispatchEvent(new Event(DOWNLOAD_COMPLETE));
		}
		
		private function onProgress(event:ProgressEvent):void
		{
			dispatchEvent(event.clone());
		}

		private function onIOError(event:IOErrorEvent):void
		{
			owner.dispatchEvent
				( new MediaErrorEvent
					( MediaErrorEvent.MEDIA_ERROR
					, false
					, false
					, new MediaError(MediaErrorCodes.IO_ERROR)
					)
				);
		}
		
		private var owner:MediaElement;
		private var _soundTransform:SoundTransform;	
		private var sound:Sound;	
		private var playing:Boolean = false;		
		private var channel:SoundChannel;
		private var lastStartTime:Number = 0;
	}
}