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
*  Contributor(s): Akamai Technologies
*  
*****************************************************/
package org.osmf.events
{
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * The MediaErrorCodes class provides static constants for error IDs.
	 * Error IDs zero through 999 are reserved for use by the
	 * framework.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	public final class MediaErrorCodes
	{
		/**
		 * Error constant for when a MediaElement fails to load due to an I/O error.
		 **/
		public static const IO_ERROR:int 								= 1;
		
		/**
		 * Error constant for when a MediaElement fails to load due to a security error.
		 **/
		public static const SECURITY_ERROR:int							= 2;

		/**
		 * Error constant for when a MediaElement encounters an asynchronous error.
		 **/
		public static const ASYNC_ERROR:int								= 3;

		/**
		 * Error constant for when a MediaElement encounters an argument error.
		 **/
		public static const ARGUMENT_ERROR:int							= 4;

		/**
		 * Error constant for when the NetLoader is unable to load a resource because
		 * of an unknown or invalid URL scheme.
		 **/
		public static const URL_SCHEME_INVALID:int						= 5;

		/**
		 * Error constant for when an HTTP GET request fails due to a client error
		 * (i.e. returns a 4xx status code).
		 **/
		public static const HTTP_GET_FAILED:int 						= 6;

		/**
		 * Error constant for when the loading of a MediaElement fails.
		 **/
		public static const MEDIA_LOAD_FAILED:int 						= 7;

		/**
		 * Error constant for when a plugin fails to load due to a version mismatch.
		 **/
		public static const PLUGIN_VERSION_INVALID:int					= 8;
				
		/**
		 * Error constant for when a plugin fails to load due to the PluginInfo not
		 * being exposed on the root Sprite of the plugin.
		 **/
		public static const PLUGIN_IMPLEMENTATION_INVALID:int			= 9;

		/**
		 * Error constant for when an audio file fails to play (e.g. due to no sound channels
		 * or no sound card being available).
		 **/
		public static const SOUND_PLAY_FAILED:int						= 10;
		
		/**
		 * Error constant that corresponds to the NetConnection.Connect.Rejected status code.
		 **/
		public static const NETCONNECTION_REJECTED:int					= 11;

		/**
		 * Error constant that corresponds to the NetConnection.Connect.InvalidApp status code.
		 **/
		public static const NETCONNECTION_APPLICATION_INVALID:int		= 12;

		/**
		 * Error constant that corresponds to the NetConnection.Connect.Failed status code.
		 **/
		public static const NETCONNECTION_FAILED:int					= 13;

		/**
		 * Error constant for when a NetConnection cannot connect due to a timeout.
		 **/
		public static const NETCONNECTION_TIMEOUT:int					= 14;

		/**
		 * Error constant for when a NetStream cannot be played.
		 **/
		public static const NETSTREAM_PLAY_FAILED:int 					= 15;

		/**
		 * Error constant that corresponds to the NetStream.Play.StreamNotFound status code.
		 **/
		public static const NETSTREAM_STREAM_NOT_FOUND:int 				= 16;
		
		/**
		 * Error constant that corresponds to the NetStream.Play.FileStructureInvalid status code.
		 **/
		public static const NETSTREAM_FILE_STRUCTURE_INVALID:int 		= 17;

		/**
		 * Error constant that corresponds to the NetStream.Play.NoSupportedTrackFound status code.
		 **/
		public static const NETSTREAM_NO_SUPPORTED_TRACK_FOUND:int 		= 18;

		/**
		 * Error constant for when a DRM system update fails.
		 **/
		public static const DRM_SYSTEM_UPDATE_ERROR:int					= 19;

		/**
		 * Error constant for when a DVRCast NetConnection cannot connect because the attempt
		 * to subscribe to the DVRCast stream fails.
		 **/
		public static const DVRCAST_SUBSCRIBE_FAILED:int				= 20;
		
		/**
		 * Error constant for when a DVRCast NetConnection cannot connect because the DVRCast
		 * application is offline.
		 **/
		public static const DVRCAST_CONTENT_OFFLINE:int					= 21;
		
		/**
		 * Error constant for when information about the DVRCast stream cannot be retrieved.
		 **/
		public static const DVRCAST_STREAM_INFO_RETRIEVAL_FAILED:int	= 22;

		/**
		 * Error constant for when the manifest file contains errors 
		 **/
		public static const F4M_FILE_INVALID:int						= 23;

		/**
		 * @private
		 * 
		 * Returns a message for the error of the specified ID.  If the error ID
		 * is unknown, returns the empty string.
		 * 
		 * @param errorID The ID for the error.
		 * 
		 * @return The message for the error with the specified ID.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		internal static function getMessageForErrorID(errorID:int):String
		{
			var message:String = "";
			
			for (var i:int = 0; i < errorMap.length; i++)
			{
				if (errorMap[i].errorID == errorID)
				{
					message = OSMFStrings.getString(errorMap[i].message);
					break;
				}
			}
			
			return message;
		}

		private static const errorMap:Array =
		[
			  {errorID:IO_ERROR,								message:OSMFStrings.IO_ERROR}
			, {errorID:SECURITY_ERROR,							message:OSMFStrings.SECURITY_ERROR}
			, {errorID:ASYNC_ERROR,								message:OSMFStrings.ASYNC_ERROR}
			, {errorID:ARGUMENT_ERROR,							message:OSMFStrings.ARGUMENT_ERROR}
			, {errorID:URL_SCHEME_INVALID,						message:OSMFStrings.URL_SCHEME_INVALID}
			, {errorID:HTTP_GET_FAILED,							message:OSMFStrings.HTTP_GET_FAILED}
			, {errorID:MEDIA_LOAD_FAILED,						message:OSMFStrings.MEDIA_LOAD_FAILED}
			, {errorID:PLUGIN_VERSION_INVALID,					message:OSMFStrings.PLUGIN_VERSION_INVALID}
			, {errorID:PLUGIN_IMPLEMENTATION_INVALID,			message:OSMFStrings.PLUGIN_IMPLEMENTATION_INVALID}
			, {errorID:SOUND_PLAY_FAILED,						message:OSMFStrings.SOUND_PLAY_FAILED}
			, {errorID:NETCONNECTION_REJECTED,					message:OSMFStrings.NETCONNECTION_REJECTED}
			, {errorID:NETCONNECTION_APPLICATION_INVALID,		message:OSMFStrings.NETCONNECTION_APPLICATION_INVALID}
			, {errorID:NETCONNECTION_FAILED,					message:OSMFStrings.NETCONNECTION_FAILED}
			, {errorID:NETCONNECTION_TIMEOUT,					message:OSMFStrings.NETCONNECTION_TIMEOUT}
			, {errorID:NETSTREAM_PLAY_FAILED, 					message:OSMFStrings.NETSTREAM_PLAY_FAILED}
			, {errorID:NETSTREAM_STREAM_NOT_FOUND,	 			message:OSMFStrings.NETSTREAM_STREAM_NOT_FOUND}
			, {errorID:NETSTREAM_FILE_STRUCTURE_INVALID,		message:OSMFStrings.NETSTREAM_FILE_STRUCTURE_INVALID}
			, {errorID:NETSTREAM_NO_SUPPORTED_TRACK_FOUND,		message:OSMFStrings.NETSTREAM_NO_SUPPORTED_TRACK_FOUND}
			, {errorID:DRM_SYSTEM_UPDATE_ERROR,					message:OSMFStrings.DRM_SYSTEM_UPDATE_ERROR}
			, {errorID:DVRCAST_SUBSCRIBE_FAILED,				message:OSMFStrings.DVRCAST_SUBSCRIBE_FAILED}
			, {errorID:DVRCAST_CONTENT_OFFLINE,					message:OSMFStrings.DVRCAST_CONTENT_OFFLINE}
			, {errorID:DVRCAST_STREAM_INFO_RETRIEVAL_FAILED,	message:OSMFStrings.DVRCAST_STREAM_INFO_RETRIEVAL_FAILED}
			, {errorID:F4M_FILE_INVALID,						message:OSMFStrings.F4M_FILE_INVALID}
		];
	}
}