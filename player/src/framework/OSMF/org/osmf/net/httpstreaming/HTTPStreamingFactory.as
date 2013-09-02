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
package org.osmf.net.httpstreaming
{
	import flash.errors.IllegalOperationError;
	
	import org.osmf.media.MediaResourceBase;

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * HTTPStreamingFactory represents a factory class for HTTP streaming elements.
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.0
	 */ 
	public class HTTPStreamingFactory
	{
		/**
		 * Creates a HTTPStreamingFileHandlerBase instance. 
		 * 
		 * @see org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase
		 */
		public function createFileHandler(resource:MediaResourceBase):HTTPStreamingFileHandlerBase
		{
			throw new IllegalOperationError("The createFileHandler() method must be overriden by derived class.");
		}

		/**
		 * Creates a HTTPStreamingIndexHandlerBase instance. 
		 * 
		 * @see org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase
		 */
		public function createIndexHandler(resource:MediaResourceBase, fileHandler:HTTPStreamingFileHandlerBase):HTTPStreamingIndexHandlerBase
		{
			throw new IllegalOperationError("The createIndexHandler() method must be overriden by derived class.");
		}
		
		/**
		 * Creates a HTTPStreamingIndexInfoBase instance.
		 * 
		 * @see org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase
		 */
		public function createIndexInfo(resource:MediaResourceBase):HTTPStreamingIndexInfoBase
		{
			throw new IllegalOperationError("The createIndexInfo() methods must be overriden by derived class.");
		}
	}
}