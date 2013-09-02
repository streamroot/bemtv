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
	 * A MediaPlayer dispatches this event when its <code>state</code> property changes.
	 *
	 * @see org.osmf.media.MediaPlayerState
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 *  @productversion FLEXOSMF 4.0	 
	 */		
	public class MediaPlayerStateChangeEvent extends Event
	{
		/**
		 * The MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE constant defines the value
		 * of the type property of the event object for a mediaPlayerStateChange
		 * event.
		 * 
		 * @eventType MEDIA_PLAYER_STATE_CHANGE
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */		
		public static const MEDIA_PLAYER_STATE_CHANGE:String = "mediaPlayerStateChange";

 		/**
		 * Constructor.
		 * 
		 * @param type Event type.
 		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 * @param state New MediaPlayerState of the MediaPlayer.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */
        public function MediaPlayerStateChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, state:String=null)
        {
        	super(type, bubbles, cancelable);
        	
            _state = state;
        }
        
		/**
		 * New MediaPlayerState of the MediaPlayer.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 *  @productversion FLEXOSMF 4.0
		 */		
        public function get state():String
        {
        	return _state;
        }
        
        /**
         * @private
         */
        override public function clone():Event
        {
        	return new MediaPlayerStateChangeEvent(type, bubbles, cancelable, _state);
        }

		private var _state:String;
	}
}