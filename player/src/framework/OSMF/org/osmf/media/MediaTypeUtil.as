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
package org.osmf.media
{
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	
	import org.osmf.utils.OSMFStrings;
	
	[ExcludeClass]

	/**
	 * @private
	 * 
	 * Utility class which contains static methods to perform common metadata functions
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaTypeUtil
	{
		/** 
		 * Checks whether we can draw a conclusion of whether the resource can be handled based on metadata. This is
		 * usually called by a loader from canHandleResource. This is a rigid implementation because it only deals with
		 * media type and MIME type.
		 * 
		 * @param resource The resource whose media type and MIME type will be checked for a match
		 * @param mediaTypesSupported The list of the media types that are supported by the caller
		 * @param mimeTypeSupported The list of mime types that are supported by the caller
		 * 
		 * @returns METADATA_MATCH_FOUND		if a match for the metadata is found
		 * 			METADATA_CONFLICTS_FOUND	if the combination of metadata is conflicting
		 * 			METADATA_MATCH_UNKNOWN		if metadata required are absent therefore there is no way to know
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function checkMetadataMatchWithResource
			( resource:MediaResourceBase
			, mediaTypesSupported:Vector.<String>
			, mimeTypesSupported:Vector.<String>
			):int
		{
			var mediaType:String  = resource ? resource.mediaType : null;
			var	mimeType:String  = resource ? resource.mimeType : null;
						
			return checkMetadataMatch(mediaType, mimeType, mediaTypesSupported, mimeTypesSupported);
		}
		
		/** 
		 * Checks whether we can draw a conclusion of whether the media type and mime type match the list of media
		 * types and/or mime types given. 
		 * 
		 * @param mediaType The media type to be searched for a match
		 * @param mimeType The mime type to be searched for a match
		 * @param mediaTypesSupported The list of the media types that are supported by the caller
		 * @param mimeTypeSupported The list of mime types that are supported by the caller
		 * 
		 * @returns METADATA_MATCH_FOUND		if there are/is match(es) for media type and/or mime type
		 * 			METADATA_CONFLICTS_FOUND	if the combination media type and mime type is conflicting, or if the MediaTypes don't match, or he MimeTypes don't match.
		 * 			METADATA_MATCH_UNKNOWN		if media type and mime type are both null therefore there is no way to know
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function checkMetadataMatch
			( mediaType:String
			, mimeType:String
			, mediaTypesSupported:Vector.<String> 
			, mimeTypesSupported:Vector.<String>
			):int
		{
			/**
			 *  Here is the matching algorithm
			 * 		if mediaType and mimeType are null, return METADATA_MATCH_UNKNOWN
			 * 
			 * 		if mediaType and mimeType are present, 
			 * 			return METADATA_MATCH_FOUND only if there are matches for bot, otherwise return METADATA_CONFLICTS_FOUND
			 * 		
			 * 		if only mediaType or mimeType is present,
			 * 			return METADATA_MATCH_FOUND if there is a match, otherwise return METADATA_CONFLICTS_FOUND
			 *
			 * */
			if (mediaType != null)
			{
				if (mimeType != null)
				{
					return (matchType(mediaType, mediaTypesSupported) && 
							matchType(mimeType, mimeTypesSupported))? METADATA_MATCH_FOUND : METADATA_CONFLICTS_FOUND;
				}
				else
				{
					return matchType(mediaType, mediaTypesSupported)? METADATA_MATCH_FOUND : METADATA_CONFLICTS_FOUND;
				}
			}
			else if (mimeType != null)
			{
				return matchType(mimeType, mimeTypesSupported)? METADATA_MATCH_FOUND : METADATA_CONFLICTS_FOUND;
			}
			
			return METADATA_MATCH_UNKNOWN;
		}
		
		/** 
		 * Checks whether a mimeType is supported
		 * 
		 * @private
		 */
		private static function matchType(type:String, typesSupported:Vector.<String>):Boolean
		{
			for (var i:int = 0; i < typesSupported.length; i++)
			{
				if (type == typesSupported[i])
				{
					return true;
				}
			}
			
			return false;
		}
		
		public static const METADATA_MATCH_FOUND:int		= 0;
		public static const METADATA_CONFLICTS_FOUND:int	= 1;
		public static const METADATA_MATCH_UNKNOWN:int		= 2;
	}
}