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
package org.osmf.events
{
	import flash.events.Event;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The MediaElementChangeEvent is dispatched by objects that have MediaElement properties,
	 * such as the MediaPlayer's media property.
	 * 
	 */ 
	public class MediaElementChangeEvent extends Event
	{
		/**
		 * @private 
		 */ 
		public static const MEDIA_ELEMENT_CHANGE:String = "mediaElementChange";
		
		/**
		 * @private 
		 * 
		 *  Constructs a new MediaElementChangeEvent.
		 */ 
		public function MediaElementChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new MediaElementChangeEvent(type, bubbles, cancelable);
		}
	}
}