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
	
	/**
	 * A MediaElement dispatches a MediaErrorEvent when it encounters an error. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaErrorEvent extends Event
	{
		/**
		 * The MediaErrorEvent.MEDIA_ERROR constant defines the value of the
		 * type property of the event object for a mediaError event.
		 * 
		 * @eventType MEDIA_ERROR 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const MEDIA_ERROR:String = "mediaError";

		/**
		 * Constructor.
		 * 
		 * @param type Event type.
 		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 * @param error The error that this event encapsulates.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MediaErrorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, error:MediaError=null)
		{
			super(type, bubbles, cancelable);
			
			_error = error;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new MediaErrorEvent(type, bubbles, cancelable, error);
		}
		
		/**
		 * The error that this event encapsulates.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get error():MediaError
		{
			return _error;
		}
		
		private var _error:MediaError;
	}
}