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
package org.osmf.utils
{
	import flash.utils.Dictionary;
	
	/**
	 * Utility class that exposes all user-facing strings.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class OSMFStrings
	{
		/**
		 * Returns the user-facing string for the given key.  All possible keys
		 * are defined as static constants on this class.  The parameters are
		 * optional substitution variables, formatted as {0}, {1}, etc.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function getString(key:String, params:Array=null):String
		{
			return resourceStringFunction(key, params);
		}
		
		/**
		 * Function that the getString methods uses to retrieve a user-facing string.
		 * 
		 * <p>This function takes a String parameter (which is expected to be one of
		 * the static consts on this class) and an optional Array of parameters
		 * which can be substituted into the String (formatted as {0}, {1}, etc.).</p>
		 * 
		 * <p>Clients can supply their own getString function to localize the strings.
		 * By default, the getString function returns an English-language String.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function get resourceStringFunction():Function
		{
			return _resourceStringFunction;
		}

		public static function set resourceStringFunction(value:Function):void
		{
			_resourceStringFunction = value;
		}
		
		// Runtime Errors
		//
		
		// CompositeTraitFactory
		
		/**
		 * @private
		 **/
		public static const COMPOSITE_TRAIT_NOT_FOUND:String 			= "compositeTraitNotFound";
		
		// General
		
		/**
		 * @private
		 **/
		public static const INVALID_PARAM:String 						= "invalidParam";

		/**
		 * @private
		 **/
		public static const NULL_PARAM:String 							= "nullParam";

		/**
		 * @private
		 **/
		public static const FUNCTION_MUST_BE_OVERRIDDEN:String			= "functionMustBeOverridden";

		/**
		 * @private
		 **/
		public static const ALREADY_ADDED:String						= "alreadyAdded";
		
		/**
		 * @private
		 **/
		public static const UNSUPPORTED_MEDIA_ELEMENT_TYPE:String		= "unsupportedMediaElementType";

		// MediaElement
		
		/**
		 * @private
		 **/
		public static const TRAIT_INSTANCE_ALREADY_ADDED:String 		= "traitInstanceAlreadyAdded";

		/**
		 * @private
		 **/
		public static const TRAIT_RESOLVER_ALREADY_ADDED:String 		= "traitResolverAlreadyAdded";
		
		// MediaPlayer
		
		/**
		 * @private
		 **/
		public static const CAPABILITY_NOT_SUPPORTED:String				= "capabilityNotSupported";
		
				/**
		 * @private
		 **/
		public static const MEDIA_LOAD_FAILED:String 					= "mediaLoadFailed";

		// LoadTrait
		
		/**
		 * @private
		 **/
		public static const MUST_SET_LOADER:String 						= "mustSetLoader";

		/**
		 * @private
		 **/
		public static const LOADER_CANT_HANDLE_RESOURCE:String 			= "loaderCantHandleResource";
		
		// PlayTrait
		
		/**
		 * @private
		 **/
		public static const PAUSE_NOT_SUPPORTED:String 					= "pauseNotSupported";

		// LoaderBase
		
		/**
		 * @private
		 **/
		public static const ALREADY_READY:String 						= "alreadyReady";

		/**
		 * @private
		 **/
		public static const ALREADY_LOADING:String 						= "alreadyLoading";

		/**
		 * @private
		 **/
		public static const ALREADY_UNLOADED:String 					= "alreadyUnloaded";

		/**
		 * @private
		 **/
		public static const ALREADY_UNLOADING:String 					= "alreadyUnloading";
		
		// CompositeDisplayObjectTrait
		
		/**
		 * @private
		 **/
		public static const INVALID_LAYOUT_RENDERER_CONSTRUCTOR:String 	= "invalidLayoutRendererConstructor";	
		
		// MediaElementLayoutTarget
		
		/**
		 * @private
		 **/
		public static const ILLEGAL_CONSTRUCTOR_INVOCATION:String		= "illegalConstructorInvocation";
		
		// MediaContainer
		
		/**
		 * @private
		 **/
		public static const DIRECT_DISPLAY_LIST_MOD_ERROR:String		= "directDisplayListModError";
		
		// HTMLLoadTrait
		
		/**
		 * @private
		 **/
		public static const NULL_SCRIPT_PATH:String						= "nullScriptPath";
		
		// Dynamic Streaming
		
		/**
		 * @private
		 **/
		public static const STREAMSWITCH_INVALID_INDEX:String			= "streamSwitchInvalidIndex";

		// Alternative Audio
		
		/**
		 * @private
		 **/
		public static const ALTERNATIVEAUDIO_INVALID_INDEX:String			= "alternativeAudioInvalidIndex";

		/**
		 * @private
		 **/
		public static const STREAMSWITCH_STREAM_NOT_IN_MANUAL_MODE:String = "streamSwitchStreamNotInManualMode";

		// DRM
		
		CONFIG::FLASH_10_1
		{
		/**
		 * @private
		 **/
		public static const DRM_METADATA_NOT_SET:String					= "drmMetadataNotSet";
		}
		
		// DVR
		
		/**
		 * @private
		 **/
		public static const DVR_MAXIMUM_RPC_ATTEMPTS:String				= "dvrMaximumRPCAttempts";
		
		/**
		 * @private
		 **/
		public static const DVR_UNEXPECTED_SERVER_RESPONSE:String		= "dvrUnexpectedServerResponse";
		
		// Flash Media Manifest Errors
		
		/**
		 * @private
		 **/
		public static const F4M_PARSE_PROFILE_MISSING:String			= "f4mProfileMissing";

		/**
		 * @private
		 **/
		public static const F4M_PARSE_MEDIA_URL_MISSING:String			= "f4mMediaURLMissing";

		/**
		 * @private
		 **/
		public static const F4M_PARSE_BITRATE_MISSING:String			= "f4mBitrateMissing";
		
		/**
		 * @private
		 **/
		public static const F4M_PARSE_VALUE_MISSING:String				= "f4mValueMissing";
		
		/**
		 * @private
		 **/
		public static const F4M_PARSE_ERROR:String						= "f4mParseError";
		
		// MediaErrorCodes
		
		/**
		 * @private
		 **/
		public static const IO_ERROR:String								= "ioError";

		/**
		 * @private
		 **/
		public static const SECURITY_ERROR:String						= "securityError";

		/**
		 * @private
		 **/
		public static const ASYNC_ERROR:String							= "asyncError";

		/**
		 * @private
		 **/
		public static const ARGUMENT_ERROR:String						= "argumentError";

		/**
		 * @private
		 **/
		public static const URL_SCHEME_INVALID:String					= "urlSchemeInvalid";

		/**
		 * @private
		 **/
		public static const HTTP_GET_FAILED:String						= "httpGetFailed";

		/**
		 * @private
		 **/
		public static const PLUGIN_VERSION_INVALID:String				= "pluginVersionInvalid";

		/**
		 * @private
		 **/
		public static const PLUGIN_IMPLEMENTATION_INVALID:String		= "pluginImplementationInvalid";

		/**
		 * @private
		 **/
		public static const SOUND_PLAY_FAILED:String					= "soundPlayFailed";

		/**
		 * @private
		 **/
		public static const NETCONNECTION_REJECTED:String				= "netConnectionRejected";

		/**
		 * @private
		 **/
		public static const NETCONNECTION_APPLICATION_INVALID:String	= "netConnectionApplicationInvalid";

		/**
		 * @private
		 **/
		public static const NETCONNECTION_FAILED:String					= "netConnectionFailed";

		/**
		 * @private
		 **/
		public static const NETCONNECTION_TIMEOUT:String				= "netConnectionTimeout";

		/**
		 * @private
		 **/
		public static const NETSTREAM_PLAY_FAILED:String 				= "netStreamPlayFailed";

		/**
		 * @private
		 **/
		public static const NETSTREAM_STREAM_NOT_FOUND:String	 		= "netStreamStreamNotFound";

		/**
		 * @private
		 **/
		public static const NETSTREAM_FILE_STRUCTURE_INVALID:String		= "netStreamFileStructureInvalid";

		/**
		 * @private
		 **/
		public static const NETSTREAM_NO_SUPPORTED_TRACK_FOUND:String	= "netStreamNoSupportedTrackFound";

		/**
		 * @private
		 **/
		public static const DRM_SYSTEM_UPDATE_ERROR:String				= "drmSystemUpdateError";

		/**
		 * @private
		 **/
		public static const DVRCAST_SUBSCRIBE_FAILED:String				= "dvrCastSubscribeFailed";

		/**
		 * @private
		 **/
		public static const DVRCAST_CONTENT_OFFLINE:String				= "dvrCastContentOffline";


		/**
		 * @private
		 **/
		public static const DVRCAST_STREAM_INFO_RETRIEVAL_FAILED:String	= "dvrCastStreamInfoRetrievalFailed";
		
		/**
		 * @private
		 **/
		public static const MULTICAST_PARAMETER_INVALID:String			= "multicastParameterInvalid";
		
		/**
		 * @private
		 **/
		public static const MULTICAST_NOT_SUPPORT_MBR:String			= "multicastNotSupportMBR";
		
		/**
		 * @private
		 **/
		public static const F4M_FILE_INVALID:String						= "f4MFileINVALID";
		
		/**
		 * @private
		 **/
		public static const F4M_MEDIA_MISSING:String 					= "f4mMediaMissing";
		
		
		private static const resourceDict:Dictionary = new Dictionary();
		{
			resourceDict[COMPOSITE_TRAIT_NOT_FOUND]	 				= "There is no composite trait for the given trait type";
			resourceDict[INVALID_PARAM]								= "Invalid parameter passed to method";
			resourceDict[NULL_PARAM]								= "Unexpected null parameter passed to method";
			resourceDict[FUNCTION_MUST_BE_OVERRIDDEN]				= "Function must be overridden";
			resourceDict[ALREADY_ADDED]								= "Child has already been added";
			resourceDict[UNSUPPORTED_MEDIA_ELEMENT_TYPE]			= "The specified media element type is not supported";
			
			resourceDict[TRAIT_INSTANCE_ALREADY_ADDED]				= "An instance of this trait class has already been added to this MediaElement";
			resourceDict[TRAIT_RESOLVER_ALREADY_ADDED]				= "A trait resolver for the specified trait type has already been added to this MediaElement";
			
			resourceDict[CAPABILITY_NOT_SUPPORTED]					= "The specified capability is not currently supported";
			resourceDict[MEDIA_LOAD_FAILED]							= "The loading of a MediaElement failed";
			
			resourceDict[MUST_SET_LOADER] 							= "Must set LoaderBase on a LoadTrait before calling load or unload";
			resourceDict[LOADER_CANT_HANDLE_RESOURCE]				= "LoaderBase unable to handle the given MediaResourceBase";
			
			resourceDict[PAUSE_NOT_SUPPORTED]						= "PlayTrait.pause cannot be invoked when canPause is false";

			resourceDict[ALREADY_READY] 							= "Loader - attempt to load an already loaded object";
			resourceDict[ALREADY_LOADING] 							= "Loader - attempt to load a loading object";
			resourceDict[ALREADY_UNLOADED] 							= "Loader - attempt to unload an already unloaded object";
			resourceDict[ALREADY_UNLOADING] 						= "Loader - attempt to unload a unloading object";
			
			resourceDict[INVALID_LAYOUT_RENDERER_CONSTRUCTOR]		= "Unable to construct LayoutRenderer implementation";
			resourceDict[ILLEGAL_CONSTRUCTOR_INVOCATION]			= "Use the static getInstance method to obtain a class instance";
			resourceDict[DIRECT_DISPLAY_LIST_MOD_ERROR]				= "The direct addition or removal of display objects onto a MediaContainer is prohibited.";

			resourceDict[NULL_SCRIPT_PATH]							= "Operation requires a valid script path";

			resourceDict[STREAMSWITCH_INVALID_INDEX]				= "Dynamic Stream Switching - Invalid index requested";
			resourceDict[STREAMSWITCH_STREAM_NOT_IN_MANUAL_MODE]	= "Dynamic Stream Switching - stream is not in manual mode";
			
			resourceDict[ALTERNATIVEAUDIO_INVALID_INDEX]			= "Alternative Audio Source Changing - Invalid index requested";

			CONFIG::FLASH_10_1
			{
			resourceDict[DRM_METADATA_NOT_SET]						= "Metadata not set on DRMServices";
			}	
			
			resourceDict[DVR_MAXIMUM_RPC_ATTEMPTS] 					= "Maximum DVRGetStreamInfo RPC attempts (%i) reached";
			resourceDict[DVR_UNEXPECTED_SERVER_RESPONSE]			= "Unexpected server response: ";
			
			resourceDict[F4M_PARSE_PROFILE_MISSING]					= "Profile missing from Bootstrap info tag";
			resourceDict[F4M_PARSE_MEDIA_URL_MISSING]				= "URL missing from Media tag";
			resourceDict[F4M_PARSE_BITRATE_MISSING]					= "Bitrate missing from Media tag";
			resourceDict[F4M_PARSE_VALUE_MISSING]					= "Value must be non-null";
			resourceDict[F4M_PARSE_ERROR]							= "Error parsing f4m file";

			resourceDict[IO_ERROR]									= "I/O error when loading media";
			resourceDict[SECURITY_ERROR]							= "Security error when loading media";
			resourceDict[ASYNC_ERROR]								= "Async error when loading media";
			resourceDict[ARGUMENT_ERROR]							= "Argument error when loading media";
			resourceDict[URL_SCHEME_INVALID]						= "Invalid URL scheme";
			resourceDict[HTTP_GET_FAILED]							= "HTTP GET failed due to a Client Error (4xx Status Code)";
			resourceDict[PLUGIN_VERSION_INVALID]					= "Plugin failed to load due to version mismatch";
			resourceDict[PLUGIN_IMPLEMENTATION_INVALID]				= "Plugin failed to load due to improper or missing implementation of PluginInfo";
			resourceDict[SOUND_PLAY_FAILED]							= "Playback failed due to no sound channels being available";
			resourceDict[NETCONNECTION_REJECTED]					= "Connection attempt rejected by FMS server";
			resourceDict[NETCONNECTION_APPLICATION_INVALID]			= "Attempting to connect to an invalid FMS application";
			resourceDict[NETCONNECTION_FAILED]						= "All NetConnection attempts failed";
			resourceDict[NETCONNECTION_TIMEOUT]						= "Timed-out trying to establish a NetConnection, or timed out due to an idle NetConnection";
			resourceDict[NETSTREAM_PLAY_FAILED] 					= "Playback failed";
			resourceDict[NETSTREAM_STREAM_NOT_FOUND]	 			= "Stream not found";
			resourceDict[NETSTREAM_FILE_STRUCTURE_INVALID]			= "File has invalid structure";
			resourceDict[NETSTREAM_NO_SUPPORTED_TRACK_FOUND]		= "No supported track found";
			resourceDict[DRM_SYSTEM_UPDATE_ERROR]					= "The update of the DRM subsystem failed";
			resourceDict[DVRCAST_SUBSCRIBE_FAILED]					= "DVRCast subscribe failed";
			resourceDict[DVRCAST_CONTENT_OFFLINE]					= "DVRCast content is offline and unavailable";
			resourceDict[DVRCAST_STREAM_INFO_RETRIEVAL_FAILED]		= "Unable to retrieve DVRCast stream info";
			resourceDict[MULTICAST_PARAMETER_INVALID]				= "The groupspec or streamName is null or empty but not both";
			resourceDict[MULTICAST_NOT_SUPPORT_MBR]					= "Multicast does not support MBR";
			resourceDict[F4M_FILE_INVALID]							= "The F4M document contains errors";
			resourceDict[F4M_MEDIA_MISSING]							= "The F4M document doesn't contain media informations.";
			
			resourceDict["missingStringResource"]					= "No string for resource {0}";
		}

		private static function defaultResourceStringFunction(resourceName:String, params:Array=null):String
		{
			var value:String = resourceDict.hasOwnProperty(resourceName) ? String(resourceDict[resourceName]) : null;
			
			if (value == null)
			{
				value = String(resourceDict["missingStringResource"]);
				params = [resourceName];
			}
			
			if (params)
			{
				value = substitute(value, params);
			}
			
			return value;
		}
		
		private static function substitute(value:String, ... rest):String
		{
			var result:String = "";

			if (value != null)
			{
				result = value;
				
				// Replace all of the parameters in the value string.
				var len:int = rest.length;
				var args:Array;
				if (len == 1 && rest[0] is Array)
				{
					args = rest[0] as Array;
					len = args.length;
				}
				else
				{
					args = rest;
				}
				
				for (var i:int = 0; i < len; i++)
				{
					result = result.replace(new RegExp("\\{"+i+"\\}", "g"), args[i]);
				}
			}
			
			return result;
		}

		private static var _resourceStringFunction:Function = defaultResourceStringFunction;
	}
}
