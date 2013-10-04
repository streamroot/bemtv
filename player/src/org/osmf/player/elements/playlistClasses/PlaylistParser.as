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

package org.osmf.player.elements.playlistClasses
{
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingURLResource;

	/**
	 * Defines a parser for the M3U plain playlist format (non-extended). All lines
	 * describe a resource, except for lines that are blank, or start with a pound
	 * sign.
	 */	
	internal class PlaylistParser
	{
		public function PlaylistParser(resourceConstructorFunction:Function = null)
		{
			this.resourceConstructorFunction = resourceConstructorFunction || this.resourceConstructorFunction;
		}
		
		public function parse(value:String):Vector.<MediaResourceBase>
		{
			var result:Vector.<MediaResourceBase>;
			
			if (value)
			{
				var lines:Array = value.split(/\r?\n/g);
				for each (var line:String in lines)
				{
					if (line && line.length)
					{
						if (line.charAt(0) != "#")
						{
							// This is a resource: add it to the result:
							result ||= new Vector.<MediaResourceBase>();
							var resource:StreamingURLResource = resourceConstructorFunction(line);
							result.push(new URLResource(line));
						}
					}
				}
			}
			
			if (result == null || result.length == 0)
			{
				throw new Error("Playlist contains no resources");
			}
			
			return result;
		}
		
		// Internals
		//
		
		private var resourceConstructorFunction:Function = constructResource;
		
		private function constructResource(url:String):MediaResourceBase
		{
			return new StreamingURLResource(url, StreamType.LIVE_OR_RECORDED);
		}
	}
}