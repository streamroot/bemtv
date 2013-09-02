package org.osmf.media.videoClasses
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The VideoSurfaceInfo class specifies the variousstatistics related to a VideoSurface object
	 * and the underlying display. A VideoSurfaceInfo object is returned in response to the 
	 * <code>VideoSurface.info</code> call, which takes a snapshot of the current state
	 * and provides these statistics through the VideoSurfaceInfo properties.
	 *
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 */
	public final class VideoSurfaceInfo
	{
		public static const UNAVAILABLE:String 	= "unavailable";
		public static const SOFTWARE:String 	= "software";
		public static const ACCELERATED:String 	= "accelerated";
		
		/**
		 * Default constructor.
		 */
		public function VideoSurfaceInfo(stageVideoInUse:Boolean, renderStatus:String, stageVideoInUseCount:int, stageVideoCount:int)
		{
			_stageVideoInUse = stageVideoInUse;
			_renderStatus = renderStatus;
			_stageVideoInUseCount = stageVideoInUseCount;
			_stageVideoCount = stageVideoCount;
		}
		
		/**
		 * Indicates if the current video surface is using StageVideo.
		 */ 
		public function get stageVideoInUse():Boolean
		{
			return _stageVideoInUse;	
		}
		
		/** 
		 * Indicates whether the video is being rendered (decoded and displayed) by hardware or software, or not at all 
		 */
		public function get renderStatus():String
		{
			return _renderStatus;
		}

		/**
		 * The number of StageVideo instances that are being currently used.
		 */ 
		public function get stageVideoInUseCount():int
		{
			return _stageVideoInUseCount;
		}
		
		/**
		 * The total number of StageVideo instances.
		 */ 
		public function get stageVideoCount():int
		{
			return _stageVideoCount;
		}
		
		/// Internals		

		protected var _stageVideoInUse:Boolean;
		protected var _renderStatus:String;		
		protected var _stageVideoInUseCount:int;
		protected var _stageVideoCount:int;		
	}
}