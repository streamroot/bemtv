/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
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
 * 
 **********************************************************/

package org.osmf.player.errors
{
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;

	/**
	 * Defines an error translator, that maps different error types into
	 * one of 4 buckets:
	 * 
	 *	1. Network problems
	 *  2. Media not found
	 *	3. Plugin loading
	 *  4. Generic
	 * 
	 */	
	public class ErrorTranslator
	{
		internal static const UNKNOWN_ERROR:String
			= "An unknown error occured. We apologize for the inconvenience.";
		
		internal static const GENERIC_ERROR:String
			= "We are having problems with playback. We apologize for the inconvenience.";
			
		internal static const NETWORK_ERROR:String
			= "We are unable to connect to the network. We apologize for the inconvenience.";
			
		internal static const NOT_FOUND_ERROR:String
			= "We are unable to connect to the content you’ve requested. We apologize for the inconvenience.";
			
		internal static const PLUGIN_FAILURE_ERROR:String
			= "We are unable to initialize the player. We apologize for the inconvenience.";
		
		/* static */
		public static function translate(error:Error):Error
		{
			var message:String = UNKNOWN_ERROR;
			var bucket:int = 0;
			
			if (error != null)
			{
				var mediaError:MediaError = error as MediaError;
				if (mediaError)
				{
					message = mediaError.message;
					if (mediaError.detail && mediaError.detail != "")
					{
						message += "\n" + mediaError.detail;
					}
				}
				else
				{
					message = error.message;
				}
				
				// See what bucket this error should go into:
				// 1: Network, 2: Media not found, 3:Plugin loading, 0: Generic:
				
				if (mediaError)
				{
					switch (mediaError.errorID)
					{
						// Generic errors: 
						case 0:
						case MediaErrorCodes.ARGUMENT_ERROR:
						case MediaErrorCodes.SOUND_PLAY_FAILED:
						case MediaErrorCodes.NETSTREAM_PLAY_FAILED:
						case MediaErrorCodes.NETSTREAM_NO_SUPPORTED_TRACK_FOUND:
						case MediaErrorCodes.DRM_SYSTEM_UPDATE_ERROR:
							bucket = GENERIC;
							break;
						
						// Network errors:
						case MediaErrorCodes.IO_ERROR:
						case MediaErrorCodes.SECURITY_ERROR:
						case MediaErrorCodes.ASYNC_ERROR:
						case MediaErrorCodes.HTTP_GET_FAILED:
						case MediaErrorCodes.NETCONNECTION_REJECTED:
						case MediaErrorCodes.NETCONNECTION_APPLICATION_INVALID:
						case MediaErrorCodes.NETCONNECTION_TIMEOUT:
						case MediaErrorCodes.NETCONNECTION_FAILED:
						case MediaErrorCodes.DVRCAST_SUBSCRIBE_FAILED:
						case MediaErrorCodes.DVRCAST_STREAM_INFO_RETRIEVAL_FAILED:
							bucket = NETWORK;
							break;
						
						// Media not found errors:
						case MediaErrorCodes.URL_SCHEME_INVALID:
						case MediaErrorCodes.MEDIA_LOAD_FAILED:
						case MediaErrorCodes.NETSTREAM_STREAM_NOT_FOUND:
						case MediaErrorCodes.NETSTREAM_FILE_STRUCTURE_INVALID:
						case MediaErrorCodes.DVRCAST_CONTENT_OFFLINE:
						case StrobePlayerErrorCodes.CONFIGURATION_LOAD_ERROR:
							bucket = NOT_FOUND;
							break;
						
						// Plugin errors:
						case MediaErrorCodes.PLUGIN_VERSION_INVALID:
						case MediaErrorCodes.PLUGIN_IMPLEMENTATION_INVALID:
							bucket = PLUGIN_FAILURE;
							break;
					}
				}
				
				// Translate the error depending on what bucket it got assigned:
				switch (bucket)
				{
					case GENERIC:
						message = GENERIC_ERROR;
						break;
					case NETWORK:
						message = NETWORK_ERROR;
						break;
					case NOT_FOUND: 
						message = NOT_FOUND_ERROR;
						break;
					case PLUGIN_FAILURE:
						message = PLUGIN_FAILURE_ERROR;
						break;
				}
			}
			
			var translatedError:Error = new Error(message);
			return translatedError;
		}
		
		// Internals
		//
		
		private static const NETWORK:int = 1;
		private static const NOT_FOUND:int = 2;
		private static const PLUGIN_FAILURE:int = 3;
		private static const GENERIC:int = 4;
	}
}