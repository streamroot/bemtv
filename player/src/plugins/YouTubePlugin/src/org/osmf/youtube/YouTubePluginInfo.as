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


package org.osmf.youtube
{
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.PluginInfo;
	import org.osmf.youtube.elements.YouTubeElement;
	import org.osmf.youtube.net.YouTubeLoader;

	public class YouTubePluginInfo extends PluginInfo
	{
		public function YouTubePluginInfo()
		{			
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			
			var loader:YouTubeLoader = new YouTubeLoader();
			//IMPORTANT: the MediaFactoryItem id should NEVER start with org.osmf
			// if we want to take precedence over the core osmf items !
			var item:MediaFactoryItem
					= new MediaFactoryItem
						( "com.youtube.YouTubePluginInfo"
						, loader.canHandleResource
						, createYouTubeElement
						, MediaFactoryItemType.STANDARD
						);
			items.push(item);
			
			super(items);
			
		}

		private function createYouTubeElement():MediaElement
		{
			return new YouTubeElement();
		}
	}
}