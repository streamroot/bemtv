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
	/**
	 * LogMessage stores the information related to a log call.
	 */ 
	public class LogMessage
	{		
		public function LogMessage( level:String,
									category:String,
									message:String,
									params:Array,
									timestamp:Date = null)
		{
			_category = category;
			_level = level;
			_message = message;
			_params = params;
			if (timestamp == null)
			{
				_timestamp = new Date();
			}
			else
			{
				_timestamp = timestamp;
			}
		}
		
		public function get formatedMessage():String
		{
			var result:String = message;
			var numParams:int = params.length;
			
			for (var i:int = 0; i < numParams; i++)
			{
				result = result.replace(new RegExp("\\{" + i + "\\}", "g"), params[i]);
			}
			
			return result;
		}

		public function get formatedTimestamp():String
		{
			return _timestamp.toLocaleString();
		}
		public function get params():Array
		{
			return _params;
		}

		public function get message():String
		{
			return _message;
		}

		public function get category():String
		{
			return _category;
		}

		public function get level():String
		{
			return _level;
		}

		public function get timestamp():Date
		{
			return _timestamp;
		}

		public function toString():String
		{
			return formatedTimestamp +" [" + level + "] " + category + " " + formatedMessage; 
		}
		
		private var _level:String;
		private var _category:String;
		private var _message:String;
		private var _params:Array;
		private var _timestamp:Date;
	}
}