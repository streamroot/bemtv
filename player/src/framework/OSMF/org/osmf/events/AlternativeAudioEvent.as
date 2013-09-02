/*****************************************************
*  
*  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.events
{
	import flash.events.Event;
	
	/**
	 * An AlternativeAudioEvent is dispatched when the properties of an AlternativeAudioTrait
	 * change.
	 *  
	 * @see org.osmf.traits.AlternativeAudioTrait
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.6
	 */		
	public class AlternativeAudioEvent extends Event
	{
		/**
		 * Dispatched when the switching state of the alternative audio stream has changed.
		 * 
		 * Usually for any successful switching operation, two AUDIO_SWITCHING_CHANGE events 
		 * will be triggered. One when the switch operation starts ( the <code>switching</code>
		 * property will be set to <code>true</code> ) and one when the operation ends ( the
		 * <code>switching</code> property will be set to <code>false</code> ).
		 * 
		 * @eventType AUDIO_SWITCHING_CHANGE  
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */		
		public static const AUDIO_SWITCHING_CHANGE:String = "audioSwitchingChange";
		
		/**
		 * Dispatched when the number of available alternative audio streams has changed..
		 * 
		 * @eventType NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE 
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */ 
		public static const NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE:String = "numAlternativeAudioStreamsChange";
		
		/**
		 * Default Constructor.
		 * 
		 * @param type Event type.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 * @param switching A <code>Boolean</code> value indicating whether an alternative audio stream switch is in progress (TRUE) or not (FALSE).
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */		
		public function AlternativeAudioEvent
			( type:String
			, bubbles:Boolean=false
			, cancelable:Boolean=false
			, switching:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_switching = switching;
		}
		
		/**
		 * Returns a <code>Boolean</code> value indicating whether an alternative audio stream switch is in progress (TRUE) or not (FALSE).
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public function get switching():Boolean
		{
			return _switching;
		}
		
		/**
		 * @private
		 * 
		 * Duplicates an instance of an AlternativeAudioEvent subclass.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		override public function clone():Event
		{
			return new AlternativeAudioEvent(type, bubbles, cancelable, switching);
		}
		
		/// Internals
		private var _switching:Boolean;	
	}
}
