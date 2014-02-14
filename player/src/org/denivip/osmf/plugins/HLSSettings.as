package org.denivip.osmf.plugins
{
	public class HLSSettings
	{
		// Buffer control
		public static var hlsBufferSizePause	:Number = 128;
		public static var hlsBufferSizeBig		:Number = 512;
		public static var hlsBufferSizeDef		:Number = 256;//OSMFSettings.hdsMinimumBufferTime;

		// reload/load playlist troubles
		public static var hlsMaxReloadRetryes	:int = 10;
		public static var hlsReloadTimeout		:int = 5000;

		// HLSIndexHandler
		public static var hlsMaxErrors:int = 10;
	}
}
