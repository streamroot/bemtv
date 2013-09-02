/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.net.httpstreaming.f4f
{
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.httpstreaming.HTTPStreamingFactory;
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;
	import org.osmf.net.httpstreaming.HTTPStreamingUtils;

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * HTTPStreamingF4FFactory represents a factory class creating Adobe HTTP streaming elements.
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.0
	 */ 
	public class HTTPStreamingF4FFactory extends HTTPStreamingFactory
	{
		/**
		 * Creates a HTTPStreamingFileHandlerBase class. 
		 * 
		 * @see org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase
		 */
		override public function createFileHandler(resource:MediaResourceBase):HTTPStreamingFileHandlerBase
		{
			return new HTTPStreamingF4FFileHandler();
		}

		/**
		 * Creates a HTTPStreamingIndexHandlerBase class. 
		 * 
		 * @see org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase
		 */
		override public function createIndexHandler(resource:MediaResourceBase, fileHandler:HTTPStreamingFileHandlerBase):HTTPStreamingIndexHandlerBase
		{
			return new HTTPStreamingF4FIndexHandler(fileHandler);				
		}
		
		/**
		 * Creates a HTTPStreamingIndexInfoBase instance.
		 * 
		 * @see org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase
		 */
		override public function createIndexInfo(resource:MediaResourceBase):HTTPStreamingIndexInfoBase
		{
			return HTTPStreamingUtils.createF4FIndexInfo(resource as URLResource);
		}
	}
}