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


package org.osmf.youtube.net
{
	import org.osmf.elements.SWFLoader;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaType;
	import org.osmf.media.MediaTypeUtil;
	import org.osmf.media.URLResource;
	import org.osmf.utils.URL;

	public class YouTubeLoader extends SWFLoader
	{
		public function YouTubeLoader()
		{
			super(false);			
		}

		
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, MEDIA_TYPES_SUPPORTED, MIME_TYPES_SUPPORTED);
			if (rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
			{
				return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
			}
			
			var url:URL = new URL((resource as URLResource).url);
			
			return url.host == "www.youtube.com" || url.host == "youtube.com";
		}
				
		private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["application/x-shockwave-flash"]);
		private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.SWF]);

	}
}