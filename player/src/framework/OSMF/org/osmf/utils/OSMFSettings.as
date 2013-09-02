package org.osmf.utils
{
	import flash.system.Capabilities;

	/**
	 * Utility class which exposes all user-facing OSMF settings.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.6
	 */ 
	public final class OSMFSettings
	{
		/**
		 * Controls OSMF’s use of StageVideo in your application. 
		 * 
		 * Setting this value to true causes OSMF to try to use StageVideo on 
		 * systems where it is available. Setting the value to false disables 
		 * the use of StageVideo and instructs OSMF to fallback to the normal 
		 * Video API. 
		 * 
		 * Changes to this value affect any new media elements that are created, 
		 * but changes have no effect on existing media elements. The default 
		 * setting for this flag is true.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public static var enableStageVideo:Boolean = true;
		
		/**
		 * Obtains whether the version of Flash Player installed on the user’s 
		 * system supports StageVideo. 
		 * 
		 * If the installed version of Flash Player is equal to or greater than 10.2, 
		 * StageVideo is supported, and the function returns true. If the installed 
		 * version of Flash Player is lower than 10.2, StageVideo is not supported, 
		 * and the function returns false.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public static function get supportsStageVideo():Boolean
		{
			return runtimeSupportsStageVideo(Capabilities.version);
		}
		
		
		/////////////////////////////////////////////
		//
		//  org.osmf.net.httpstreaming.HTTPNetStream
		//
		/////////////////////////////////////////////
		/**
		 * @private
		 */
		public static var hdsMinimumBufferTime:Number = 4;
		
		/**
		 * @private
		 */
		public static var hdsAdditionalBufferTime:Number = 2;
		
		/**
		 * @private
		 */
		public static var hdsBytesProcessingLimit:Number = 65000;
		
		/**
		 * @private
		 */
		public static var hdsMainTimerInterval:int = 25;

		
		/////////////////////////////////////////////
		//
		//  org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FIndexHandler
		//
		/////////////////////////////////////////////
		/**
		 * @private
		 */
		public static var hdsDefaultFragmentsThreshold:uint = 5;
		
		/**
		 * @private
		 */
		public static var hdsMinimumBootstrapRefreshInterval:uint = 2000;
		
		
		/////////////////////////////////////////////
		//
		//  org.osmf.net.httpstreaming.HTTPStreamSource
		//
		/////////////////////////////////////////////
		/**
		 * @private
		 * 
		 * The amount of seconds OSMF will stay behind the live point in dvr scenarios.
		 */
		public static var hdsDVRLiveOffset:Number = 4;
		

		/**
		 * @private
		 * 
		 * The amount of seconds OSMF will stay behind the live point in the pure live scenario.
		 */
		public static var hdsPureLiveOffset:Number = 5;

		/////////////////////////////////////////////
		//
		//  org.osmf.elements.ManifestLoaderBase
		//
		/////////////////////////////////////////////
		/**
		 * @private
		 * 
		 * The timeout (in milliseconds) for the parsing of an F4M.
		 * This timeout applies to the actual parsing of the F4M 
		 * (including the download of referenced F4Ms, external DRM metadata etc.)
		 * 
		 * The download of the initial F4M is not affected by this timeout.
		 */
		public static var f4mParseTimeout:Number = 30000;
		
		/**
		 * @private
		 * 
		 * Maximum retries in case of a loading failure.
		 */
		public static var hdsMaximumRetries:Number = 5;
		
		/**
		 * @private
		 * 
		 * The value used to increment the timeout value on each retry. The first time
		 * the framework will wait x, on the second try it will wait x+hdsTimeoutAdjustmentOnRetry,
		 * and so on. 
		 */
		public static var hdsTimeoutAdjustmentOnRetry:Number = 4000;
		
		/**
		 * @private
		 * 
		 * Initial timeout for fragment downloads. 
		 */
		public static var hdsFragmentDownloadTimeout:Number = 4000;
		
		/**
		 * @private
		 * 
		 * Initial timeout for index downloads.
		 */
		public static var hdsIndexDownloadTimeout:Number = 4000;
		
		/**
		 * @private
		 */
		internal static function runtimeSupportsStageVideo(runtimeVersion:String):Boolean
		{
			if (runtimeVersion == null)
				return false;
			
			var osArray:Array = runtimeVersion.split(' ');
			if (osArray.length < 2)
				return false;
			
			var osType:String = osArray[0]; 
			var versionArray:Array = osArray[1].split(',');
			if (versionArray.length < 2)
					return false;
			var majorVersion:Number = parseInt(versionArray[0]);
			var majorRevision:Number = parseInt(versionArray[1]);
			
			return (
						majorVersion > 10 ||
						(majorVersion == 10 && majorRevision >= 2)
					);
		}
	}
}