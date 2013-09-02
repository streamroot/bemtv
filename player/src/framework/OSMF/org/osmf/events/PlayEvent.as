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
	 * A PlayEvent is dispatched when the properties of a PlayTrait change.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class PlayEvent extends Event
	{
		/**
		 * The PlayEvent.CAN_PAUSE_CHANGE constant defines the value
		 * of the type property of the event object for a canPauseChange
		 * event.
		 * 
		 * @eventType canPauseChange
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const CAN_PAUSE_CHANGE:String = "canPauseChange";

		/**
		 * The PlayEvent.PLAY_STATE_CHANGE constant defines the value
		 * of the type property of the event object for a playStateChange
		 * event.
		 * 
		 * @eventType playStateChange
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const PLAY_STATE_CHANGE:String = "playStateChange";
		
		/**
		 * Constructor.
		 * 
		 * @param type Event type.
 		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 * @param playState New PlayState of the PlayTrait.
		 * @param bytes New value of bytesLoaded or bytesTotal.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function PlayEvent
							( type:String,
							  bubbles:Boolean=false,
							  cancelable:Boolean=false,
							  playState:String=null,
							  canPause:Boolean=false
							)
		{
			super(type, bubbles, cancelable);
			
			_playState = playState;
			_canPause = canPause;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new PlayEvent(type, bubbles, cancelable, playState, canPause);
		}

		/**
		 * New PlayState of the PlayTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get playState():String
		{
			return _playState;
		}

		/**
		 * New canPause state of the PlayTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get canPause():Boolean
		{
			return _canPause;
		}
		
		// Internals
		//
		
		private var _playState:String;
		private var _canPause:Boolean;
	}
}
