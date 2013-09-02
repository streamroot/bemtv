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
	
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import org.osmf.elements.audioClasses.AudioAudioTrait;
	import org.osmf.elements.audioClasses.AudioPlayTrait;
	import org.osmf.elements.audioClasses.AudioSeekTrait;
	import org.osmf.elements.audioClasses.AudioTimeTrait;
	import org.osmf.elements.audioClasses.SoundAdapter;
	import org.osmf.elements.audioClasses.SoundLoadTrait;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.DefaultTraitResolver;
	import org.osmf.media.LoadableElementBase;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.*;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.OSMFStrings;

   /** 
	 * AudioElement is a media element specifically created for audio playback.
	 * It supports both streaming and progressive formats.
	 * <p>AudioElement can load and present any MP3 or AAC file.
	 * It supports MP3 files over HTTP, as well as audio-only streams from
	 * Flash Media Server.</p>
	 * <p>The basic steps for creating and using an AudioElement are:
	 * <ol>
	 * <li>Create a new URLResource pointing to the URL of the audio stream or file
	 * containing the sound to be loaded.</li>
	 * <li>Create the new AudioElement, 
	 * passing the URLResource as a parameter.</li>
	 * <li>Create a new MediaPlayer.</li>
	 * <li>Assign the AudioElement to the MediaPlayer's <code>media</code> property.</li>
	 * <li>Control the media using the MediaPlayer's methods, properties, and events.</li>
	 * <li>When done with the AudioElement, set the MediaPlayer's <code>media</code>
	 * property to null.  This will unload the AudioElement.</li>
	 * </ol>
	 * </p>
	 * 
	 * @includeExample AudioElementExample.as -noswf
	 * 
	 * @see org.osmf.media.URLResource
	 * @see org.osmf.media.MediaElement
	 * @see org.osmf.media.MediaPlayer
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class AudioElement extends LoadableElementBase
	{
		/**
		 * Constructor.  
		 * @param resource URLResource that points to the audio source that the AudioElement
		 * will use.
		 * @param loader Loader used to load the sound. This must be either a
		 * NetLoader (for streaming audio) or a SoundLoader (for progressive audio).
		 * If null, the appropriate Loader will be created based on the type of the
		 * resource.
		 * @see org.osmf.net.NetLoader
		 * 
		 * @throws ArgumentError If loader is neither a NetLoader nor a SoundLoader.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function AudioElement(resource:URLResource=null, loader:LoaderBase=null)
		{
			super(resource, loader);
			
			if (!(loader == null || loader is NetLoader || loader is SoundLoader))
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
		}
		
		/**
       	 * Defines the duration that the element's TimeTrait will expose until the
       	 * element's content is loaded.
       	 * 
       	 * Setting this property to a positive value results in the element becoming
       	 * temporal. Any other value will remove the element's TimeTrait, unless the
       	 * loaded content is exposing a duration. 
       	 *  
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 */       	
		public function get defaultDuration():Number
		{
			return defaultTimeTrait ? defaultTimeTrait.duration : NaN;
		}

      	public function set defaultDuration(value:Number):void
		{
			if (isNaN(value) || value < 0)
			{
				if (defaultTimeTrait != null)
				{
					// Remove the default trait if the default duration
					// gets set to not a number:
					removeTraitResolver(MediaTraitType.TIME);
					defaultTimeTrait = null;
				}
			}
			else 
			{
				if (defaultTimeTrait == null)
				{		
					// Add the default trait if when default duration
					// gets set:
					defaultTimeTrait = new ModifiableTimeTrait();
		       		addTraitResolver
		       			( MediaTraitType.TIME
		       			, new DefaultTraitResolver
		       				( MediaTraitType.TIME
		       				, defaultTimeTrait
		       				)
		       			);
		  		}
		  		
		  		defaultTimeTrait.duration = value; 
			}	
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

		/**
		 * @private
		 */
		override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase):LoadTrait
		{
			return 	loader is NetLoader
				  ? new NetStreamLoadTrait(loader, resource)
				  : new SoundLoadTrait(loader, resource);
		}

		
		/**
		 * @private 
		 */ 
		override protected function processReadyState():void
		{
			var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;

			var timeTrait:TimeTrait;
			
			soundAdapter = null;
			stream = null;
			
			// Different paths for streaming vs. progressive.
			var netLoadTrait:NetStreamLoadTrait = loadTrait as NetStreamLoadTrait;
			if (netLoadTrait)
			{
				// Streaming Audio
				//
				
				stream = netLoadTrait.netStream;
				
				stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
				netLoadTrait.connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent, false, 0, true);
				
				var reconnectStreams:Boolean = false;

				CONFIG::FLASH_10_1	
				{
					if (loader is NetLoader)
					{
						reconnectStreams = (loader as NetLoader).reconnectStreams;
					}
				}
				
				addTrait(MediaTraitType.PLAY, new NetStreamPlayTrait(stream, resource, reconnectStreams, netLoadTrait.connection));
				timeTrait = new NetStreamTimeTrait(stream, resource, defaultDuration);
				addTrait(MediaTraitType.TIME, timeTrait);
				addTrait(MediaTraitType.SEEK, new NetStreamSeekTrait(timeTrait, loadTrait, stream));
				addTrait(MediaTraitType.AUDIO, new NetStreamAudioTrait(stream));	
				addTrait(MediaTraitType.BUFFER, new NetStreamBufferTrait(stream));
			}
			else
			{
				// Progressive Audio
				//
				
				var soundLoadTrait:SoundLoadTrait = loadTrait as SoundLoadTrait;

				soundAdapter = new SoundAdapter(this, soundLoadTrait.sound);
				
				addTrait(MediaTraitType.PLAY, new AudioPlayTrait(soundAdapter));
				timeTrait = new AudioTimeTrait(soundAdapter);
				addTrait(MediaTraitType.TIME, timeTrait);
				addTrait(MediaTraitType.SEEK, new AudioSeekTrait(timeTrait, soundAdapter));
				addTrait(MediaTraitType.AUDIO, new AudioAudioTrait(soundAdapter));	
			}
		}	
				
		/**
		 * @private 
		 */ 
		override protected function processUnloadingState():void
		{
			if (stream != null)
			{
				stream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
			}
			var netLoadTrait:NetStreamLoadTrait = getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
			if (netLoadTrait != null)
			{
				netLoadTrait.connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
			}
			
			removeTrait(MediaTraitType.PLAY);
			removeTrait(MediaTraitType.SEEK);
			removeTrait(MediaTraitType.TIME);
			removeTrait(MediaTraitType.AUDIO);
			removeTrait(MediaTraitType.BUFFER);

			if (soundAdapter != null)
			{
				// Halt the sound.
				soundAdapter.pause();
			}
			soundAdapter = null;
			stream = null;
		}	
		
     	private function onNetStatusEvent(event:NetStatusEvent):void
     	{     		
     		var error:MediaError = null;
 			switch (event.info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_FAILED:
				case NetStreamCodes.NETSTREAM_FAILED:
					error = new MediaError(MediaErrorCodes.NETSTREAM_PLAY_FAILED, event.info.description);
					break;
				case NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND:
					error = new MediaError(MediaErrorCodes.NETSTREAM_STREAM_NOT_FOUND, event.info.description);
					break;
				case NetStreamCodes.NETSTREAM_PLAY_FILESTRUCTUREINVALID:
					error = new MediaError(MediaErrorCodes.NETSTREAM_FILE_STRUCTURE_INVALID, event.info.description);
					break;
				case NetStreamCodes.NETSTREAM_PLAY_NOSUPPORTEDTRACKFOUND:
					error = new MediaError(MediaErrorCodes.NETSTREAM_NO_SUPPORTED_TRACK_FOUND, event.info.description);
					break;	
				case NetConnectionCodes.CONNECT_IDLE_TIME_OUT:
					error = new MediaError(MediaErrorCodes.NETCONNECTION_TIMEOUT, event.info.description);
					break;
			}
					
			if (error != null)
			{
				dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, error));
			}
     	}
     	
		private function get alternateLoaders():Vector.<LoaderBase>
		{
			if (_alternateLoaders == null)
			{
				_alternateLoaders = new Vector.<LoaderBase>()
			
				_alternateLoaders.push(new SoundLoader());
				_alternateLoaders.push(new NetLoader());
			}

			return _alternateLoaders;
		}
		
		private var soundAdapter:SoundAdapter;
		private var stream:NetStream;
		private var defaultTimeTrait:ModifiableTimeTrait;
		private var _alternateLoaders:Vector.<LoaderBase>;
	}
}