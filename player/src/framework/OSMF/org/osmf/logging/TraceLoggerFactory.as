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
	import flash.utils.Dictionary;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * This class extends LoggerFactory. It is the associated logger factory
	 * for the TraceLogger. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class TraceLoggerFactory extends LoggerFactory
	{
		/**
		 * Constructor.
		 **/
		public function TraceLoggerFactory(filter:String=null)
		{
			super();
			
			loggers = new Dictionary();
			_filter = filter;
		}
		
		/**
		 * Optional filter to apply to all loggers.  If specified, then
		 * only those Loggers whose category matches or contains this filter
		 * string (which is case-sensitive) will be logged.
		 **/
		public function get filter():String
		{
			return _filter;
		}
		
		public function set filter(value:String):void
		{
			_filter = value;
		}

		/**
		 * @private
		 */
		override public function getLogger(category:String):Logger
		{
			var logger:Logger = loggers[category];
			
			if (logger == null)
			{
				if (filter != null && category.indexOf(filter) == -1)
				{
					logger = new Logger(category);
				}
				else
				{
					logger = new TraceLogger(category);
				}
				loggers[category] = logger;
			}
			
			return logger;
		}
		
		// Internals
		//
		
		private var loggers:Dictionary;
		private var _filter:String;
	}
}
