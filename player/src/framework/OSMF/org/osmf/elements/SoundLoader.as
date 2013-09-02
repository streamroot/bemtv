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
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	import org.osmf.elements.audioClasses.SoundLoadTrait;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaType;
	import org.osmf.media.MediaTypeUtil;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.*;

	/**
	 * SoundLoader is a loader that is capable of loading progressive audio files.
	 * 
	 * <p>The audio file is loaded from the URL provided by the
	 * <code>resource</code> property of the LoadTrait that is passed
	 * to the SoundLoader's <code>load()</code> method.</p>
	 *
	 * @see org.osmf.elements.AudioElement
	 * @see org.osmf.traits.LoadTrait
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	public class SoundLoader extends LoaderBase
	{
		/**
		 * Constructor.
		 * 
		 * @param checkPolicyFile Indicates whether the SoundLoader should try to download
		 * a URL policy file from the loaded sound's server before beginning to load the
		 * sound.  The default is false.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function SoundLoader(checkPolicyFile:Boolean=false)
		{
			super();
			
			this.checkPolicyFile = checkPolicyFile;
		}
		
		/**
		 * @private
		 * 
		 * Indicates whether this SoundLoader is capable of handling the specified resource.
		 * Returns <code>true</code> for URLResources with MP3 extensions, M4A extensions, or
		 * media/mime types that match MP3.
		 * @param resource Resource proposed to be loaded.
		 */ 
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
			if (rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
			{
				return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
			}			
					
			/*
			 * The rules for URL checking is outlined as below:
			 * 
			 * If the URL is null or empty, we assume being unable to handle the resource
			 * If the URL has no protocol, we check for file extensions
			 * 		If the protocol is progressive (file, http, https), we check for file extension
			 *
			 * We assume being unable to handle the resource for conditions not mentioned above
			 */
			 
			var urlResource:URLResource = resource as URLResource;
			if (urlResource == null || urlResource.url == null || urlResource.url.length <= 0)
			{
				return false;
			}
			var url:URL = new URL(urlResource.url);
			if (url.protocol == "")
			{
				return url.path.search(/\.mp3$|\.m4a$/i) != -1;
			}		
			if (url.protocol.search(/file$|http$|https$/i) != -1)
			{
				return (url.path == null ||
						url.path.length <= 0 ||
						url.path.indexOf(".") == -1 ||
						url.path.search(/\.mp3$|\.m4a$/i) != -1);
			}
			
			return false;
		}
		
		/**
		 * @private
		 * 
		 * Loads the Sound object.
		 * <p>Updates the LoadTrait's <code>loadedState</code> property to LOADING
		 * while loading and to READY upon completing a successful load.</p> 
		 * 
		 * @see org.osmf.traits.LoadState
		 * @param loadTrait LoadTrait to be loaded.
		 */ 
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			var soundLoadTrait:SoundLoadTrait = loadTrait as SoundLoadTrait;

			updateLoadTrait(soundLoadTrait, LoadState.LOADING);

			var sound:Sound = new Sound();
			toggleSoundListeners(sound, true);

			var urlRequest:URLRequest = new URLRequest((soundLoadTrait.resource as URLResource).url.toString());
			var context:SoundLoaderContext = new SoundLoaderContext(1000, checkPolicyFile);
			
			try
			{
				sound.load(urlRequest, context);
			}
			catch (ioError:IOError)
			{
				onIOError(null, ioError.message);
			}
			catch (securityError:SecurityError)
			{
				handleSecurityError(securityError.message);
			}

			function toggleSoundListeners(sound:Sound, on:Boolean):void
			{
				if (on)
				{
					sound.addEventListener(ProgressEvent.PROGRESS, onProgress)
					sound.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				}
				else
				{
					sound.removeEventListener(ProgressEvent.PROGRESS, onProgress)
					sound.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				}
			}

			function onProgress(event:ProgressEvent):void
			{
				// There's no "loaded" event associated with the Sound class.
				// We can't rely on the "open" event, because that can get
				// fired prior to an "ioError" event (which seems like a bug).
				// But we can assume that if we get a progress event with some
				// bytes, then the load has succeeded.
				//
				
				// Note that we check that we'll receive at least 15 bytes.  Why?
				// If the request returns a 404, there's no way for us to know
				// that (without waiting for an IO Error event, by which time we
				// want to have already signaled READY).  15 bytes is roughly the
				// size of a 404, and presumably we'll never need to load content
				// so small, so this seems like a safe heuristic to use.
				//
				// The second condition is to cover the case where a load is
				// immediately followed by an unload.  In such a case, we might
				// still get a ProgressEvent, but we want to ignore it since we've
				// already changed the state to unloaded.
				if (event.bytesTotal >= MIN_BYTES_TO_RECEIVE &&
					soundLoadTrait.loadState == LoadState.LOADING)
				{
					toggleSoundListeners(sound, false);

					soundLoadTrait.sound = sound;
					updateLoadTrait(soundLoadTrait, LoadState.READY);
				}
			}

			function onIOError(ioEvent:IOErrorEvent, ioEventDetail:String=null):void
			{	
				toggleSoundListeners(sound, false);
				
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
						, false
						, false
						, new MediaError
							( MediaErrorCodes.IO_ERROR
							, ioEvent ? ioEvent.text : ioEventDetail
							)
						)
					);
			}

			function handleSecurityError(securityErrorDetail:String):void
			{	
				toggleSoundListeners(sound, false);
				
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
						, false
						, false
						, new MediaError
							( MediaErrorCodes.SECURITY_ERROR
							, securityErrorDetail
							)
						)
					);
			}
		}

		/**
		 * @private
		 * 
		 * Unloads the Sound object.  
		 * 
		 * <p>Updates the LoadTrait's <code>loadState</code> property to UNLOADING
		 * while unloading and to UNINITIALIZED upon completing a successful unload.</p>
		 *
		 * @param loadTrait LoadTrait to be unloaded.
		 * @see org.osmf.traits.LoadState
		 */ 
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			var soundLoadTrait:SoundLoadTrait = loadTrait as SoundLoadTrait;
			
			updateLoadTrait(soundLoadTrait, LoadState.UNLOADING);
			try
			{
				if (soundLoadTrait.sound != null)
				{
					soundLoadTrait.sound.close();
				}
			}
			catch (error:IOError)
			{
				// Swallow, either way the Sound is now unloaded.
			}
			updateLoadTrait(soundLoadTrait, LoadState.UNINITIALIZED);
		}
		
		// Internals
		//

		private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["audio/mpeg"]);
		private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.AUDIO]);
		
		private static const MIN_BYTES_TO_RECEIVE:int = 16;
		
		private var checkPolicyFile:Boolean;
	}
}