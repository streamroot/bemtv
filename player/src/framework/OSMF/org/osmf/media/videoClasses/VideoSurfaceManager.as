package org.osmf.media.videoClasses
{
	[ExcludeClass]
	
	import flash.events.Event;
	import flash.events.StageVideoEvent;
	import flash.events.VideoEvent;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.utils.Dictionary;
	
	CONFIG::PLATFORM import flash.display.Stage;
	CONFIG::MOCK	 import org.osmf.mock.Stage;
	
	CONFIG::PLATFORM import flash.media.StageVideo;
	CONFIG::MOCK     import org.osmf.mock.StageVideo;

	CONFIG::LOGGING  import org.osmf.logging.Logger;	
	
	/**
	 * @private
	 * 
	 * VideoSurfaceManager manages the workflow related to StageVideo support.
	 */ 
	internal class VideoSurfaceManager
	{	
		public function registerVideoSurface(videoSurface:VideoSurface):void
		{			
			videoSurface.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			videoSurface.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		public function get stageVideoInUseCount():int
		{
			var result:int = 0;
			for each (var renderer:* in activeVideoSurfaces)
			{
				if (renderer && renderer is StageVideo)
				{
					result ++;
				}
			}
			return result;
		}
		
		public function get stageVideoCount():int
		{
			return _stage ? _stage.stageVideos.length : 0;
		}
		/**
		 * Registers the current stage.
		 * VideoSurfaceManager object will monitor the changes in StageVideo availability
		 * and trigger for each available VideoSurface the switch to appropiate mode.
		 */
		internal function registerStage(stage:Stage):void
		{
			_stage = stage;
			_stage.addEventListener("stageVideoAvailability", onStageVideoAvailability);
			
			stageVideoIsAvailable = _stage.hasOwnProperty("stageVideos") && _stage.stageVideos.length > 0;
		}		
	
		internal function provideRenderer(videoSurface:VideoSurface):void
		{
			if (videoSurface == null)
				return;
				
			switchRenderer(videoSurface);
		}

		internal function releaseRenderer(videoSurface:VideoSurface):void
		{
			videoSurface.clear(true);
			activeVideoSurfaces[videoSurface] = null;
			videoSurface.switchRenderer(null);
		}
		
		/**
		 * @private
		 * Event handler for StageVideoAvailability event dispatched by stage.
		 */
		private function onStageVideoAvailability(event:Event):void
		{	
			if (!event.hasOwnProperty(AVAILABILITY))
			{
				// If the event has no AVAILABILITY property then
				// we should ignore it.
				CONFIG::LOGGING
				{
					logger.warn("stageVideoAvailability event received. No {0} property", AVAILABILITY);
				}
				return;
			}
			else
			{
				// Check if stageVideoAvailability has been changed 
				// If yes we will need to go through all existing VideoSurface 
				// objects and force a manual switch to the correct mode.
				var currentStageVideoIsAvailable:Boolean = event[AVAILABILITY] == AVAILABLE;
				if (stageVideoIsAvailable != currentStageVideoIsAvailable)
				{
					CONFIG::LOGGING
					{
						logger.info("stageVideoAvailability changed. Previous value = {0}; Current value = {1}", stageVideoIsAvailable, currentStageVideoIsAvailable);
					}
					
					stageVideoIsAvailable = currentStageVideoIsAvailable;
					for (var key:* in activeVideoSurfaces)
					{
						var videoSurface:VideoSurface = key as VideoSurface;
						if (videoSurface != null && videoSurface.info.stageVideoInUse != stageVideoIsAvailable)
						{
							// If the VideoSurface is in StageVideo mode but the StageVideo is not available
							// anymore then switch to Video. If the StageVideo is not used but the StageVideo
							// has become available, then switch to StageVideo.
							switchRenderer(videoSurface);	
						}
					}
				}	
			}
		}
		
		/**
		 * @private
		 * Event handler for VideoSurface ADDED_TO_STAGE events.
		 * When VideoSurface objects are added to stage, the VideoSurfaceManager 
		 * will try to switch VideoSurface direclty in StageVideo mode.
		 */
		private function onAddedToStage(event:Event):void
		{			
			if (_stage == null)
			{				
				registerStage(event.target.stage);
			}
			
			// When added to Stage, try to use the StageVideo mode 
			// directly, without waiting for availability event.
			provideRenderer(event.target as VideoSurface);		
		}
		
		/**
		 * @private
		 * Event handler for VideoSurface REMOVE_FROM_STAGE events.
		 * When VideoSurface is removed from stage, The VideoSurfacManager
		 * will unregister any informations.
		 */ 
		private function onRemovedFromStage(event:Event):void
		{
			releaseRenderer(event.target as VideoSurface);
		}
				
		/**
		 * A StageVideo instance might become unavailable while it is being used.
		 * Switches to Video once this happens.
		 */ 
		private function onStageVideoRenderState(event:StageVideoEvent):void
		{
			if (event.status == UNAVAILABLE)
			{
				for (var key:* in activeVideoSurfaces)
				{
					var videoSurface:VideoSurface = key as VideoSurface;
					if (event.target == videoSurface.stageVideo)
					{
						videoSurface.stageVideo = null;
						switchRenderer(videoSurface);
						break;
					}
				}
			}
		}
		
		private function switchRenderer(videoSurface:VideoSurface):void
		{
			var renderer:*;
			if (!stageVideoIsAvailable)
			{
				if (videoSurface.video == null)
				{
					videoSurface.video =  videoSurface.createVideo();
				}
				renderer = videoSurface.video;
			}
			else
			{
				// Find a StageVideo instance that is not in use
				var stageVideo:StageVideo = null;
				for (var i:int = 0; i < _stage.stageVideos.length; i++)
				{
					stageVideo = _stage.stageVideos[i];
					for (var key:* in activeVideoSurfaces)
					{
						if (stageVideo == activeVideoSurfaces[key])
						{
							stageVideo = null;
						}
					}
					if (stageVideo != null)
					{							
						break;
					}
				}
				
				if (stageVideo != null)
				{
					// Retrieve the current max depth, so that we surface the newly used
					// StageVideos to the top
					var maxDepth:int = 0;
					for (var index:int = 0; index < _stage.stageVideos.length; index++)
					{
						if (maxDepth < _stage.stageVideos[index].depth)
						{
							maxDepth = _stage.stageVideos[index].depth;
						}
					}	

					// There is an available stageVideo instance. 
					activeVideoSurfaces[videoSurface] = stageVideo;
					videoSurface.stageVideo = stageVideo;
					renderer = stageVideo;			
					stageVideo.depth = maxDepth + 1;
					renderer.addEventListener(StageVideoEvent.RENDER_STATE, onStageVideoRenderState);				
				}
				else
				{
					// All the StageVideo instances are currrently used. Fallback to Video.
					if (videoSurface.video == null)
					{
						videoSurface.video = videoSurface.createVideo();
					}
					renderer = videoSurface.video;
				}
			}
			
			activeVideoSurfaces[videoSurface] = renderer;
			
			// Start using the new renderer.
			videoSurface.switchRenderer(renderer);
			
			VideoSurface.stageVideoCount = stageVideoCount;
			VideoSurface.stageVideoInUseCount = stageVideoInUseCount;
		}							
		
		internal var activeVideoSurfaces:Dictionary = new Dictionary(true);
		
		/**
		 * @private
		 * Stage reference. 
		 * It is set the first time a VideoSurface is added to the stage.
		 */
		private var _stage:Stage = null;		
		
		/**
		 * @private
		 * Status flag signaling the availability of StageVideo.
		 */
		private var stageVideoIsAvailable:Boolean = false;
		
		CONFIG::LOGGING 
		private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.media.videoClasses.VideoSurfaceManager");

		private static const AVAILABILITY:String = "availability";
		private static const AVAILABLE:String = "available";
		private static const UNAVAILABLE:String = "unavailable"
	}
}