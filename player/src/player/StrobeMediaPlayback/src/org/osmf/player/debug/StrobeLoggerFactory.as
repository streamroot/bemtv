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

package org.osmf.player.debug
{
	import flash.utils.Dictionary;
	
	import org.osmf.logging.Logger;
	import org.osmf.logging.LoggerFactory;

	/**
	 * StrobeLoggerFactory is needed for hooking into the OSMF logging framework.
	 */ 
	public class StrobeLoggerFactory extends LoggerFactory
	{
		public function StrobeLoggerFactory(logHandler:LogHandler)
		{
			loggers = new Dictionary();
			this.logHandler = logHandler;
		}
		
		/**
		 * @inheritDoc
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function getLogger(name:String):Logger
		{
			var logger:Logger = loggers[name];
			
			if (logger == null)
			{
				logger = new StrobeLogger(name, logHandler);
				loggers[name] = logger;
			}
			
			return logger;
		}
		
		// internal
		//
		
		private var loggers:Dictionary;	
		private var logHandler:LogHandler;
	}
}