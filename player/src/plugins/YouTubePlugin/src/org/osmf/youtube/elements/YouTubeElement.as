/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.youtube.elements
{

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	import org.osmf.elements.SWFElement;
	import org.osmf.elements.loaderClasses.LoaderLoadTrait;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.LoadableElementBase;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.youtube.YouTubePlayerProxy;
	import org.osmf.youtube.YouTubeUtils;
	import org.osmf.youtube.net.YouTubeLoader;
	import org.osmf.youtube.traits.YouTubeAudioTrait;
	import org.osmf.youtube.traits.YouTubeDisplayObjectTrait;
	import org.osmf.youtube.traits.YouTubeDynamicStreamTrait;
	import org.osmf.youtube.traits.YouTubePlayTrait;
	import org.osmf.youtube.traits.YouTubeSeekTrait;
	import org.osmf.youtube.traits.YouTubeTimeTrait;

	/**
	 * YouTubeElement is a media element that wraps the YouTube Chromeless Player
	 *
	 * <p>This element supports playing of YouTube videos via YouTube's chromeless player.</p
	 *
	 * <p>The YouTubeElement uses the YouTubeLoader to load the chromeless player,
	 *  and a set of specialized YouTube* traits that are wrapping around the YouTube API. </p>
	 *
	 * <p>YouTubeElement supports all playback features exposed by the chromeless API, including
	 * dynamic streaming!</p>
	 *
	 * @see org.osmf.youtube.traits.YouTubeDynamicStreamTrait
	 * @see http://code.google.com/apis/youtube/flash_api_reference.html
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class YouTubeElement extends SWFElement
	{
		/**
		 * Constructor.
		 *
		 * @param resource URLResource that points to a plain YouTube movie url.
		 * @param loader The YouTubeLoader used to load the movies.
		 * If null this class will create it's own instance.
		 */
		public function YouTubeElement(resource:URLResource=null, loader:YouTubeLoader=null)
		{
			if (loader == null)
			{
				loader = new YouTubeLoader();
			}			
			super(resource, loader);
		}


		// Overrides
		//

		/**
		 * The sole purpose of overriding this is to replace the original resource
		 * with one pointing at the YouTube's chromeless player. The original YouTube url
		 * is movie is saved in a local variable for future use.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase):LoadTrait
		{
			return new LoaderLoadTrait(loader, new URLResource(YouTubePlayerProxy.CHROMELESS_PLAYER));
		}
		
		
		/**
		 * Gets a reference to the YouTube chromeless player, when load completes.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override protected function processReadyState():void
		{
			var loader:Loader = (getTrait(MediaTraitType.LOAD) as LoaderLoadTrait).loader;
			
			var loaderInfo:LoaderInfo = loader.contentLoaderInfo;
			
			// Use duck typing, to avoid adding conditional compiling just for this
			// UncaughtError handler
			if (loaderInfo != null && loaderInfo.hasOwnProperty("uncaughtErrorEvents"))
			{
				function onUncaughtError(event:Event):void
				{
					event.stopImmediatePropagation();
					event.preventDefault();
				}
					
				loaderInfo["uncaughtErrorEvents"].addEventListener("uncaughtError", onUncaughtError);
			}
			
			youTubePlayer = new YouTubePlayerProxy(loader.content);
			youTubePlayer.addEventListener("onReady", onYouTubePlayerReady);
			youTubePlayer.addEventListener("onStateChange", onYouTubeStateChange);
			youTubePlayer.addEventListener("onError", onYouTubeError);
		}

		/**
		 *  @private
		 */
		override protected function processUnloadingState():void
		{
			removeTrait(MediaTraitType.DISPLAY_OBJECT);
			removeTrait(MediaTraitType.LOAD);
			removeTrait(MediaTraitType.PLAY);
			removeTrait(MediaTraitType.AUDIO);
			removeTrait(MediaTraitType.SEEK);
			removeTrait(MediaTraitType.DYNAMIC_STREAM);
			youTubePlayer.destroy();
		}

		// Internals
		//

		/**
		 * YouTube player is ready to receive api calls, so we try to load the requested movie.
		 *
		 * @param event YouTube event.
		 */
		private function onYouTubePlayerReady(event:Event):void
		{
			var url:String = (resource as URLResource).url;
			var id:String = YouTubeUtils.getYouTubeID(url);
			if (id)
			{				
				youTubePlayer.cueVideoById(id);
			}
			else
			{
				var mediaError:MediaError
				= new MediaError(MediaErrorCodes.URL_SCHEME_INVALID
					, YOUTUBE_ERRORS[99]);
				
				dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
							, false
							, false
							, mediaError
						)
					);
			}
		}

		/**
		 * Event handler for YouTube's state changes.
		 *
		 * <p>This is responsible for adding the MediaTraits for this element. Some can be added safely
		 * when the player signals that the video has been cued, but for others we need more info
		 * that is available only after playback begins. For those we initiate a timer when
		 * YouTube player fires the YOUTUBE_STATE_PLAYING event.</p>
		 *
		 * <p>The YouTubeDynamicStreamTrait needs to be added as early as possible in order to
		 * be consistent with the framework's handling of DynamicTrait, which usually is added
		 * by the loader. Later adding might not be detected for clients of the YouTubeElement.</p>
		 * 
		 * @param event
		 */
		private function onYouTubeStateChange(event:Event):void
		{
			switch(event["data"])
			{
				case YouTubePlayerProxy.YOUTUBE_STATE_CUED:
					//removeTrait(MediaTraitType.LOAD);
					//addTrait(MediaTraitType.LOAD, new YouTubeLoadTrait(youTubePlayer));
				
					if (youTubePlayer.getAvailableQualityLevels().length > 1)
					{
						//Important: add this as early as possible
						addTrait(MediaTraitType.DYNAMIC_STREAM, new YouTubeDynamicStreamTrait(youTubePlayer));
					}
					
					addTrait(MediaTraitType.DISPLAY_OBJECT, new YouTubeDisplayObjectTrait(youTubePlayer));
					addTrait(MediaTraitType.AUDIO, new YouTubeAudioTrait(youTubePlayer));
					addTrait(MediaTraitType.PLAY, new YouTubePlayTrait(youTubePlayer));		
					if (hasTrait(MediaTraitType.SEEK))
					{
						removeTrait(MediaTraitType.SEEK);
					}
					addTimeAndSeekTrait(null);
					break;

				case YouTubePlayerProxy.YOUTUBE_STATE_PLAYING:
					
					if (youTubePlayer.getAvailableQualityLevels().length > 1)
					{
						//Important: add this as early as possible
						if (!hasTrait(MediaTraitType.DYNAMIC_STREAM))
						{		
							// Add resource level metadata to the MediaElement
							var mediaMetadata:Object = metadata.getValue("org.osmf.player.metadata.MediaMetadata");
							if (mediaMetadata)
							{
								var streamItems:Vector.<DynamicStreamingItem> = YouTubeUtils.constructStreamItems(youTubePlayer.getAvailableQualityLevels());
								var resourceMetadata:Object = mediaMetadata.resourceMetadata;
								resourceMetadata.streamItems = streamItems;
								metadata.addValue("org.osmf.player.metadata.MediaMetadata", mediaMetadata);
							}
							
							// The trait should be added only after the resourceMetadata has been updated.
							addTrait(MediaTraitType.DYNAMIC_STREAM, new YouTubeDynamicStreamTrait(youTubePlayer));	
						}
					}
					else
					{
						removeTrait(MediaTraitType.DYNAMIC_STREAM);
					}

					break;				
			}
		}

		/**
		 * Lazy add YouTubeTimeTrait and YouTubeSeekTrait.
		 *
		 * @param event TimerEvent
		 */
		private function addTimeAndSeekTrait(event:TimerEvent):void
		{			
			var duration:int = youTubePlayer.getDuration();
			var timeTrait:YouTubeTimeTrait = new YouTubeTimeTrait(duration, youTubePlayer);
			
			addTrait(MediaTraitType.TIME, timeTrait);
			// Temporary keep this commented out until we validate that there are not injections caused by it.
//			if (metadata)
//			{
//				// WORKARROUND: AutoRewind and autoDynamicStreamSwitch need to be turned off
//				// otherwise the playback never stops. 
//				var mediaPlayer:MediaPlayer = metadata.getValue("org.osmf.media.MediaPlayer");
//				if (mediaPlayer)
//				{
//					//mediaPlayer.autoRewind = false;
//					//mediaPlayer.autoDynamicStreamSwitch = false;
//				}
//			}
//			
			addTrait(MediaTraitType.SEEK, new YouTubeSeekTrait(timeTrait, youTubePlayer));
			
			// Temporary keep this commented out until we validate that there are not injections caused by it.
//			dispatchEvent(new TimeEvent
//				( TimeEvent.DURATION_CHANGE
//				, false
//				, false
//				, duration
//				));
		}

		/**
		 * Converts the YouTube error into a MediaError and dispatches a MediaErrorEvent.
		 *
		 * @param event YouTube event.
		 */
		private function onYouTubeError(event:Event):void
		{
			var mediaError:MediaError
					= new MediaError(1000 + event["data"], 
						YOUTUBE_ERRORS[event["data"]]);
					
			dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, mediaError));
		}

		/**
		 * Reference to YouTube's chromeless player
		 * 
		 * TODO: This should be private, but it's currently internal because some
		 * unit tests reference it.  Ideally we would refactor the unit tests to
		 * not rely on internal state.  Once we've done that, we should make this
		 * private.
		 */
		internal var youTubePlayer:YouTubePlayerProxy = null;


		/* static */

		/**
		 * How much to wait before trying to read the movie's duration
		 * 
		 */
		private static const METADATA_DELAY:int = 1000;
		
		private static const YOUTUBE_ERROR_MESSAGE:String = "YouTube Error";
		
		private static const YOUTUBE_ERRORS:Object = 
		{
				99: "A YouTube ID could not be extracted from the provided URL. Please confirm that the URL is in valid YouTube form and is properly encoded."	
				,100: "The requested YouTube ID does not match any video found on YouTube.com."
				,101: "The requested YouTube video has been removed or is marked as private."
				,150: "The requested video does not permit playback on sites external to YouTube.com."
		}
		private static const YOUTUBE_ID_ERROR_MESSAGE:String = "The YouTube ID could not be extracted. Make sure it's a valid YouTube URL and check that it's properly URL encoded.";

		
	}
}