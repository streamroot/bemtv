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
	 * Log is the central access point for logging messages.
	 *  
	 * @includeExample LoggerExample.as -noswf
	 * @includeExample ExampleLoggerFactory.as -noswf
	 * @includeExample ExampleLogger.as -noswf
	 * 
	 * @see org.osmf.logging.Logger
	 * @see org.osmf.logging.LoggerFactory
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class Log
	{
		/**
		 * The LoggerFactory used across the application. 
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function get loggerFactory():LoggerFactory
		{
			return _loggerFactory;
		}

		public static function set loggerFactory(value:LoggerFactory):void
		{
			_loggerFactory = value;
		}
		
		/**
		 * Returns a logger for the specified category. 
		 * 
		 * @param category The category that identifies a particular logger
		 * @return the logger identified by the category
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function getLogger(category:String):Logger
		{
			CONFIG::LOGGING
			{
				if (_loggerFactory == null)
				{
					_loggerFactory = new TraceLoggerFactory();
				}
			}
			
			return (_loggerFactory == null)? null : _loggerFactory.getLogger(category);
		}

		// Internals
		//
		
		private static var _loggerFactory:LoggerFactory;
	}
}