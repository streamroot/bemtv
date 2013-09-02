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
package org.osmf.net.httpstreaming
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;

	/**
	 * Dispatched when the index handler or file handler obtain the current fragment duration.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="fragmentDuration", type="org.osmf.events.HTTPStreamingEvent")]
	
	/**
	 * Dispatched when the index handler or file handler provides additional script data tags.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="scriptData", type="org.osmf.events.HTTPStreamingEvent")]
	
	/**
	 * Dispatched when the index handler encounters an unrecoverable error, such as an invalid 
	 * bootstrap box or an empty server base url.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="fileError", type="org.osmf.events.HTTPStreamingEvent")]

	/**
	 * Dispatched when the time bias value becomes available, after beginProcessFile
	 * has been invoked.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="notifyTimeBias", type="org.osmf.events.HTTPStreamingFileHandlerEvent")]
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * This class serves as the interface of http streaming file handler. The responsibility
	 * of file hanlder is to parse downloaded bytes of the file as well as processing the
	 * bytes according to the protocol between file handler and http net stream.
	 */
	public class HTTPStreamingFileHandlerBase extends EventDispatcher
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function HTTPStreamingFileHandlerBase()
		{
		}
		
		/**
		 * Begins the processing of a file.
		 * 
		 * Subclasses must override to provide a specific implementation.
		 * 
		 * @param seek Indicates whether this requested was prompted by a seek.
		 * @param seekTime Indicates the requested seek time.  Only valid if the
		 * seek param is true.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function beginProcessFile(seek:Boolean, seekTime:Number):void
		{
			throw new IllegalOperationError("The beginProcessFile() method must be overridden by HttpStreamingFileHandlerBase's derived class.");
		}
		
		/**
		 * The minimum number of bytes that must be retrieved from the file.
		 * 
		 * Subclasses must override to provide a specific implementation. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get inputBytesNeeded():Number
		{
			throw new IllegalOperationError("The inputBytesNeeded() method must be overridden by HttpStreamingFileHandlerBase's derived class.");
		}
		
		/**
		 * Processes a segment of the file. 
		 * 
		 * Subclasses must override to provide a specific implementation.
		 * Note that if the input has a large number of available bytes, you
		 * MUST process only a reasonable number of them (e.g., 5000 at
		 * a time), or else there may be significant frame drop.
		 * 
		 * @param input An interface that gives access to the bytes of the file.
		 * 
		 * @return A ByteArray containing the bytes that should be fed to the
		 * NetStream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function processFileSegment(input:IDataInput):ByteArray
		{
			throw new IllegalOperationError("The processFileSegment() method must be overridden by HttpStreamingFileHandlerBase's derived class.");
		}
		
		/**
		 * Ends the processing of the file.
		 * 
		 * Subclasses must override to provide a specific implementation.
		 * 
		 * @param input An interface that gives access to the remaining bytes of the file.
		 * 
		 * @return A ByteArray containing the remaining bytes of the file, that should be
		 * fed to the NetStream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function endProcessFile(input:IDataInput):ByteArray
		{
			throw new IllegalOperationError("The endProcessFile() method must be overridden by HttpStreamingFileHandlerBase's derived class.");
		}
		
		/**
		 * Flushes a segment of the file.  This method is called if the next call
		 * to beginProcessFile is for a seek operation, or to the "next" segment
		 * but with a different quality level.
		 * 
		 * Subclasses must override to provide a specific implementation.
		 * 
		 * @param input An interface that gives access to the remaining bytes of the file.
		 * 
		 * @return A ByteArray containing the remaining bytes of the file, that should be
		 * fed to the NetStream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function flushFileSegment(input:IDataInput):ByteArray
		{
			throw new IllegalOperationError("The flushFileSegment() method must be overridden by HttpStreamingFileHandlerBase's derived class.");
		}
	}
}