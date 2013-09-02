package org.osmf.media.videoClasses
{	
	[ExcludeClass]
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetStream;
	
	CONFIG::PLATFORM import flash.display.Stage;
	CONFIG::MOCK	 import org.osmf.mock.Stage;
	
	CONFIG::LOGGING  import org.osmf.logging.Logger;	
	
	/**
	 * @private
	 * 
	 * VideoSurface class wraps the display object where
	 * a video should be displayed.
	 */
	public class VideoSurface extends Sprite
	{
		/**
		 * Default constructor.
		 */
		public function VideoSurface(useStageVideo:Boolean = true, createVideo:Function = null)
		{
			// Enable double click event on VideoSurface.
			// This is done in order to make a VideoSurface object behave
			// like a Video object (handles double click events).
			this.doubleClickEnabled = true;
			
			if (createVideo != null)
			{
				this.createVideo = createVideo;
			}
			else
			{
				this.createVideo = function():Video{return new Video();};
			}
			
			if (useStageVideo)
			{
				// Be carefull, this code needs to be in a different function.
				// See the method docs for details.
				register();
			}
			else
			{
				switchRenderer(this.createVideo());
			}
		}
		
		/**
		 * Returns a VideoSurfaceInfo object whose properties contain statistics 
		 * about the surface state. The object is a snapshot of the current state.
		 */
		public function get info():VideoSurfaceInfo
		{
			return new VideoSurfaceInfo(stageVideo != null, renderStatus, stageVideoInUseCount, stageVideoCount);
		}
		
		/**
		 * Specifies a video stream to be displayed within the boundaries of the Video object in the application.
		 */
		public function attachNetStream(netStream:NetStream):void
		{
			this.netStream = netStream;
			if (currentVideoRenderer)
			{
				currentVideoRenderer.attachNetStream(netStream);
			}
		}
		
		/**
		 * Clears the image currently displayed in the Video object (not the video stream).
		 */ 
		public function clear(clearStageVideoObject:Boolean = false):void
		{
			if (currentVideoRenderer)
			{
				if (currentVideoRenderer == video)
				{
					video.clear();
				}
				else
				{
					// Flash Player limitation: there is no clear concept for StageVideo.
					// The snippet below is not 
					if (clearStageVideoObject)
					{
						stageVideo.depth = 0;
						stageVideo.viewPort = new Rectangle(0, 0, 0, 0);
					}
				}
			}
		}
		
		/**
		 * Indicates the type of filter applied to decoded video as part of post-processing.
		 */	
		public function get deblocking():int
		{
			return _deblocking;				
		}
		
		public function set deblocking(value:int):void
		{
			if (_deblocking != value)
			{
				_deblocking = value;
				if (currentVideoRenderer is Video)
				{
					currentVideoRenderer.deblocking = _deblocking;
				}
			}
		}
		
		/**
		 * Specifies whether the video should be smoothed (interpolated) when it is scaled.
		 */
		public function get smoothing():Boolean
		{
			return _smoothing;
		}
		
		public function set smoothing(value:Boolean):void
		{
			if (_smoothing != value)
			{
				_smoothing = value;
				if (currentVideoRenderer is Video)
				{
					currentVideoRenderer.smoothing = _smoothing;
				}
			}
		}
		
		override public function set visible(value:Boolean):void
		{			
			_visible = value;
			if (videoSurfaceManager)
			{
				if (_visible)
				{
					videoSurfaceManager.provideRenderer(this);
				}
				else
				{
					videoSurfaceManager.releaseRenderer(this);
				}
			}
		}
		
		override public function get visible():Boolean
		{
			return _visible;
		}		
		
		/**
		 * An integer specifying the height of the video stream, in pixels.
		 */
		public function get videoHeight():int
		{
			return currentVideoRenderer ? currentVideoRenderer.videoHeight : surfaceRect.height;
		}
		
		/**
		 * An integer specifying the width of the video stream, in pixels.
		 */
		public function get videoWidth():int
		{
			return currentVideoRenderer ? currentVideoRenderer.videoWidth : surfaceRect.width;
		}
		
		/// Overrides
		override public function set x(value:Number):void
		{
			super.x = value;
			surfaceRect.x = 0;	
			updateView();
		}
		
		override public function set y(value:Number):void
		{
			super.y = value;			
			surfaceRect.y = 0;
			updateView();
		}
		
		override public function get height():Number
		{
			return surfaceRect.height;
		}
		
		override public function set height(value:Number):void
		{
			if (surfaceRect.height != value)
			{
				surfaceRect.height = value;
				updateView();
			}
		}
		
		override public function get width():Number
		{
			return surfaceRect.width;
		}
		
		override public function set width(value:Number):void
		{
			if (surfaceRect.width != value)
			{
				surfaceRect.width = value;
				updateView();
			}
		}
		
		// Internals
		
		/**
		 * Returns a valid rectangle object which can be used 
		 * both with StageVideo and with graphics object. If any
		 * of the x,y, width, height properties is NaN, it will
		 * be reset to 0.
		 */ 
		private static function updateRect(rect:Rectangle):Rectangle
		{
			var result:Rectangle = rect;
			if (isNaN(result.x))
			{
				result.x = 0;
			}
			if (isNaN(result.y))
			{
				result.y = 0;
			}
			if (isNaN(result.width))
			{
				result.width = 0;
			}
			if (isNaN(result.height))
			{
				result.height = 0;
			}
			
			return result;
		}
		
		internal function updateView():void
		{
			if (currentVideoRenderer == null)
			{
				return;
			}
			
			var actualRect:Rectangle = updateRect(surfaceRect);
			if (currentVideoRenderer == stageVideo)
			{
				var viewPort:Rectangle = new Rectangle();
				viewPort.topLeft = localToGlobal(actualRect.topLeft);
				viewPort.bottomRight = localToGlobal(actualRect.bottomRight);
				stageVideo.viewPort = viewPort;
				
				if (surfaceShape == null)
				{
					surfaceShape = new Shape();
				}
				
				surfaceShape.graphics.clear();
				surfaceShape.graphics.drawRect(0, 0, actualRect.width, actualRect.height);
				surfaceShape.alpha = 0;
				
				addChild(surfaceShape);
			}
			else
			{	
				currentVideoRenderer.x = actualRect.x;
				currentVideoRenderer.y = actualRect.y;
				currentVideoRenderer.height = actualRect.height;
				currentVideoRenderer.width = actualRect.width;
			}
		}
		
		internal function switchRenderer(renderer:*):void
		{
			if (currentVideoRenderer == renderer)
			{
				CONFIG::LOGGING
				{
					logger.info("switchRenderer reusing the same renderer. Do nothing");
				}
				return;
			}
			
			CONFIG::LOGGING
			{
				logger.info("switchRenderer. currentVideoRenderer = {0}; the new renderer = {1}", currentVideoRenderer != null ? currentVideoRenderer.toString() : "null", renderer);
			}
			
			if (currentVideoRenderer)
			{				
				currentVideoRenderer.attachNetStream(null);
				if (currentVideoRenderer == video)
				{
					video = null;
					removeChild(currentVideoRenderer);
				}
				else
				{					
					// If the renderer switched from StageVideo to Video we need to clear the viewPort of the
					// stageVideo isntance that is no longer used.
					if (stageVideo != null)
						stageVideo.viewPort = new Rectangle(0,0,0,0);			
					stageVideo = null;
					
					if (surfaceShape != null)
					{
						surfaceShape.graphics.clear();
						removeChild(surfaceShape);
						surfaceShape = null;
					}
				}
			}
			
			currentVideoRenderer = renderer;
			
			if (currentVideoRenderer)
			{
				currentVideoRenderer.attachNetStream(netStream);
				
				if (currentVideoRenderer is DisplayObject)
				{				
					video = currentVideoRenderer;
					video.deblocking = _deblocking;
					video.smoothing = _smoothing;
					addChild(currentVideoRenderer);					
				}						
				else
				{
					stageVideo = currentVideoRenderer;
				}
				updateView();
				currentVideoRenderer.addEventListener("renderState", onRenderState);
			}
		}
		
		/**
		 * @private
		 * Event handler for render events dispatched both by Video and StageVideo objects.
		 */
		private function onRenderState(event:Event):void
		{		
			if (event.hasOwnProperty("status"))
			{
				renderStatus = event["status"];
			}
		}
		
		/**
		 * This code needs to be in a separate function.
		 * 
		 * If used directly in the constructor, a runtime error is being 
		 * thrown on Flash Player 10.0 and 10.1.
		 */ 
		private function register():void
		{
			if (videoSurfaceManager == null)
			{
				videoSurfaceManager = new VideoSurfaceManager();
			}
			videoSurfaceManager.registerVideoSurface(this);
		}
		
		/**
		 * @private
		 * Internal surface used for actual rendering.
		 */		
		internal static var videoSurfaceManager:VideoSurfaceManager = null;		
		internal static var stageVideoInUseCount:int = 0;
		internal static var stageVideoCount:int = 0;
		
		internal var createVideo:Function;		
		
		/** 
		 * @private
		 * StageVideo instance used by this VideoSurface.
		 * 
		 * Do not link to StageVideo, to avoid runtime issues on older FP versions, < 10.2. 
		 */ 
		internal var stageVideo:* = null;
		internal var video:Video = null;	
		private var currentVideoRenderer:* = null;	
		
		private var netStream:NetStream;
		
		/**
		 * @private
		 * Internal rect used for representing the actual size.
		 */
		private var surfaceRect:Rectangle = new Rectangle(0,0,0,0);
		private var invalidSurfaceRect:Boolean = false;
		
		private var surfaceShape:Shape = null;
		
		private var _deblocking:int 	= 0;
		private var _smoothing:Boolean 	= false;
		private var _visible:Boolean = true;
		
		
		/**
		 * @private
		 * Internal render status information.
		 */
		private var renderStatus:String;
		
		CONFIG::LOGGING 
		private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.media.videoClasses.VideoSurface");
		
	}
}