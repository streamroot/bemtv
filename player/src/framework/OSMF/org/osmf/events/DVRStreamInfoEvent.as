/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.events
{
	import flash.events.Event;

	[ExcludeClass]

	/**
	 * @private
	 **/
	public class DVRStreamInfoEvent extends Event
	{
		public static const DVRSTREAMINFO:String = "DVRStreamInfo";
		
		/** 
		 * @private
		 */
		public function DVRStreamInfoEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, info:Object = null)
		{
			super(type, bubbles, cancelable);
			_info = info;
		}
		
		/** 
		 * @private
		 */
		override public function clone():Event
		{
			return new DVRStreamInfoEvent(type, bubbles, cancelable, info)
		}
		
		/** 
		 * @private
		 */
		public function get info():Object
		{
			return _info;
		}
		
		//
		// Internal
		
		private var _info:Object;
	}
}
