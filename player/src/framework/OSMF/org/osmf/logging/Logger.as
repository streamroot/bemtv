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
package org.osmf.logging
{
	/**
	 * Logger defines the capabilities of a logger, the object that OSMF
	 * applications interact with to write logging messages.
	 *  
	 * @includeExample LoggerExample.as -noswf
	 * @includeExample ExampleLoggerFactory.as -noswf
	 * @includeExample ExampleLogger.as -noswf
	 * 
	 * @see org.osmf.logging.Log
	 * @see org.osmf.logging.LoggerFactory
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class Logger
	{
		/**
		 * Constructor.
		 * 
		 * @param category The category value for the logger.
		 **/
		public function Logger(category:String)
		{
			super();
			
			_category = category;
		}
		
		/**
		 * The category value for the logger.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 **/
		public function get category():String
		{
			return _category;
		}
		
		/**
		 * Logs a message with a "debug" level.
		 * 
		 * <p>Debug messages are informational messages that are fine-grained,
		 * and intended to be helpful when debugging.</p>
		 * 
		 * @param message The information to log. This string can contain special 
	 	 * special marker characters of the form {x}, where x is a zero-based
	 	 * index that will be replaced with the additional parameters found at 
	 	 * that index if specified.
	 	 * 
	 	 * @param ...rest Additional parameters that can be subsituted in the  
	 	 * message parameter at each "{x}" location, where x is an zero-based
	 	 * integer index into the Array of values specified.
	 	 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function debug(message:String, ... rest):void
		{
		}
		
		/**
		 * Logs a message with a "info" level.
		 *  
		 * <p>Info messages are intended to be informational, as opposed to
		 * indicating a concern.</p>
	 	 * 
		 * @param message The information to log. This string can contain special 
	 	 * special marker characters of the form {x}, where x is a zero-based
	 	 * index that will be replaced with the additional parameters found at 
	 	 * that index if specified.
	 	 * 
	 	 * @param ...rest Additional parameters that can be subsituted in the  
	 	 * message parameter at each "{x}" location, where x is an zero-based
	 	 * integer index into the Array of values specified.
		 *
  		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function info(message:String, ... rest):void
		{
		}
		
		/**
		 * Logs a message with a "warn" level.
		 *  
		 * <p>Warn messages are intended to warn of events that could be
		 * harmful to the operation of the application.</p>
	 	 * 
		 * @param message The information to log. This string can contain special 
	 	 * special marker characters of the form {x}, where x is a zero-based
	 	 * index that will be replaced with the additional parameters found at 
	 	 * that index if specified.
	 	 * 
	 	 * @param ...rest Additional parameters that can be subsituted in the  
	 	 * message parameter at each "{x}" location, where x is an zero-based
	 	 * integer index into the Array of values specified.
	 	 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function warn(message:String, ... rest):void
		{
		}
		
		/**
		 * Logs a message with a "error" level.
		 *  
		 * <p>Error messages are intended to capture error events that might
		 * still allow the application to continue running.</p>
	 	 * 
		 * @param message The information to log. This string can contain special 
	 	 * special marker characters of the form {x}, where x is a zero-based
	 	 * index that will be replaced with the additional parameters found at 
	 	 * that index if specified.
	 	 * 
	 	 * @param ...rest Additional parameters that can be subsituted in the  
	 	 * message parameter at each "{x}" location, where x is an zero-based
	 	 * integer index into the Array of values specified.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function error(message:String, ... rest):void
		{
		}
		
		/**
		 * Logs a message with a "fatal" level.
		 *  
		 * <p>Fatal messages are intended to capture error events that are
		 * likely to lead to application failure.</p>
	 	 * 
		 * @param message The information to log. This string can contain special 
	 	 * special marker characters of the form {x}, where x is a zero-based
	 	 * index that will be replaced with the additional parameters found at 
	 	 * that index if specified.
	 	 * 
	 	 * @param ...rest Additional parameters that can be subsituted in the  
	 	 * message parameter at each "{x}" location, where x is an zero-based
	 	 * integer index into the Array of values specified.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function fatal(message:String, ... rest):void
		{
		}
		
		private var _category:String;
	}
}