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
	 * A MediaPlayer dispatches a MediaPlayerCapabilityChangeEvent when its
	 * capabilities change.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaPlayerCapabilityChangeEvent extends Event
	{
		/**
		 * The MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE constant defines
		 * the value of the type property of the event object for a canPlayChange
		 * event.
		 * 
		 * @eventType canPlayChange 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const CAN_PLAY_CHANGE:String = "canPlayChange";
		
		/**
		 * The MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE constant defines
		 * the value of the type property of the event object for a canSeekChange
		 * event.
		 * 
		 * @eventType canSeekChange 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const CAN_SEEK_CHANGE:String = "canSeekChange";
	
		/**
		 * The MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE constant defines
		 * the value of the type property of the event object for a temporalChange
		 * event.
		 * 
		 * @eventType temporalChange 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const TEMPORAL_CHANGE:String = "temporalChange";
	
		/**
		 * The MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE constant defines
		 * the value of the type property of the event object for a hasAudioChange
		 * event.
		 * 
		 * @eventType hasAudioChange 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const HAS_AUDIO_CHANGE:String = "hasAudioChange";
		
		/**
		 * This event is dispatched by MediaPlayer when its <code>hasAlternativeAudio</code>
		 * property has changed.
		 * 
		 * @eventType hasAlternativeAudioChange 
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */	
		public static const HAS_ALTERNATIVE_AUDIO_CHANGE:String = "hasAlternativeAudioChange";

		/**
		 * The MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE constant defines
		 * the value of the type property of the event object for a isDynamicStreamChange
		 * event.
		 * 
		 * @eventType isDynamicStreamChange 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const IS_DYNAMIC_STREAM_CHANGE:String = "isDynamicStreamChange";
			
		/**
		 * The MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE constant defines
		 * the value of the type property of the event object for a canLoadChange
		 * event.
		 * 
		 * @eventType canLoadChange 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const CAN_LOAD_CHANGE:String = "canLoadChange";
		
		/**
		 * The MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE constant defines
		 * the value of the type property of the event object for a canBufferChange
		 * event.
		 * 
		 * @eventType canBufferChange 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const CAN_BUFFER_CHANGE:String = "canBufferChange";
		
		/**
		 * The MediaPlayerCapabilityChangeEvent.HAS_DRM_CHANGE constant defines
		 * the value of the type property of the event object for a hasDRMChange
		 * event.
		 * 
		 * @eventType hasDRMChange 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const HAS_DRM_CHANGE:String = "hasDRMChange";
		
		/**
		 * The MediaPlayerCapabilityChangeEvent.HAS_DISPLAY_OBJECT_CHANGE constant defines
		 * the value of the type property of the event object for a hasDisplayObjectChange
		 * event.
		 * 
		 * @eventType hasDisplayObjectChange 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public static const HAS_DISPLAY_OBJECT_CHANGE:String = "hasDisplayObjectChange";
						
		/**
		 * Constructor.
		 * 
		 * @param type Event type.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 * @param enabled Indicates whether the MediaPlayer has a particular capability
		 * as a result of the change described in the <code>type</code> parameter.
		 * Value of <code>true</code> means the player has the capability as a
		 * result of the change, <code>false</code> means it does not.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MediaPlayerCapabilityChangeEvent
							( type:String
							, bubbles:Boolean=false
							, cancelable:Boolean=false
							, enabled:Boolean=false				  
							)
		{
			super(type, bubbles, cancelable);
			
			_enabled = enabled;
		}
		
		/**
		 * Indicates whether the MediaPlayer has the capability
		 * described by the event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}

		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new MediaPlayerCapabilityChangeEvent(type, bubbles, cancelable, _enabled);
		}
		
		/// Internals
		private var _enabled:Boolean;
	}
}