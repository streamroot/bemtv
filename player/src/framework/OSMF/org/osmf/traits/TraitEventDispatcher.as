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
package org.osmf.traits
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.osmf.events.AlternativeAudioEvent;
	import org.osmf.events.AudioEvent;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.DVREvent;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	
	
	/**
	 * Dispatched when the <code>duration</code> property of the media has changed.
	 * 
	 * @eventType org.osmf.events.TimeEvent.DURATION_CHANGE
	 * 
	 * 	@langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="durationChange", type="org.osmf.events.TimeEvent")]
	 
	/**
	 * Dispatched when the media has completed playback.
	 * 
	 * @eventType org.osmf.events.TimeEvent.COMPLETE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	[Event(name="complete", type="org.osmf.events.TimeEvent")]
	 	 
	/**
	 * Dispatched when the <code>volume</code> property of the media has changed.
	 * 
	 * @eventType org.osmf.events.AudioEvent.VOLUME_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 	 
	[Event(name="volumeChange", type="org.osmf.events.AudioEvent")]   
	 
	/**
	 * Dispatched when the <code>muted</code> property of the media has changed.
	 * 
	 * @eventType org.osmf.events.AudioEvent.MUTED_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	[Event(name="mutedChange", type="org.osmf.events.AudioEvent")] 
	 
	/**
	 * Dispatched when the <code>pan</code> property of the media has changed.
	 * 
	 * @eventType org.osmf.events.AudioEvent.PAN_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 	 
	[Event(name="panChange", type="org.osmf.events.AudioEvent")]

	/**
	 * Dispatched when the <code>playing</code> or <code>paused</code> property of the media has changed.
	 * 
	 * @eventType org.osmf.events.PlayEvent.PLAY_STATE_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 	 	 		
	[Event(name="playStateChange", type="org.osmf.events.PlayEvent")]
	
	/**
	 * Dispatched when the <code>canPause</code> property has changed.
	 * 
	 * @eventType org.osmf.events.PlayEvent.CAN_PAUSE_CHANGE
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 * 
	 */
	[Event(name="canPauseChange",type="org.osmf.events.PlayEvent")]	
		
	/**
	 * Dispatched when the <code>displayObject</code> property of the media has changed.
	 * 
	 * @eventType org.osmf.events.DisplayObjectEvent.DISPLAY_OBJECT_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 	 	 		
	[Event(name="displayObjectChange", type="org.osmf.events.DisplayObjectEvent")]
	
	/**
	 * Dispatched when the <code>mediaWidth</code> and/or <code>mediaHeight</code> property of the 
	 * media has changed.
	 * 
	 * @eventType org.osmf.events.DisplayObjectEvent.MEDIA_SIZE_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */		
	[Event(name="mediaSizeChange", type="org.osmf.events.DisplayObjectEvent")]
	 
	/**
	 * Dispatched when the <code>seeking</code> property of the media has changed.
	 * 
	 * @eventType org.osmf.events.SeekEvent.SEEKING_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 	
	[Event(name="seekingChange", type="org.osmf.events.SeekEvent")]
	    
	/**
	 * Dispatched when a dynamic stream switch change occurs.
	 * 
	 * @eventType org.osmf.events.DynamicStreamEvent.SWITCHING_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="switchingChange",type="org.osmf.events.DynamicStreamEvent")]
	
	/**
	 * Dispatched when the number of dynamic streams has changed.
	 * 
	 * @eventType org.osmf.events.DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="numDynamicStreamsChange",type="org.osmf.events.DynamicStreamEvent")]
	
	/**
	 * Dispatched when the <code>autoSwitch</code> property has changed.
	 * 
	 * @eventType org.osmf.events.DynamicStreamEvent.AUTO_SWITCH_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="autoSwitchChange",type="org.osmf.events.DynamicStreamEvent")]

	/**
	 * Dispatched when an alternative audio stream switch is requested, completed,
	 * or has failed.
	 * 
	 * @eventType org.osmf.events.AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE
	 *  
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.6
	 */
	[Event(name="audioSwitchingChange",type="org.osmf.events.AlternativeAudioEvent")]
	
	/**
	 * Dispatched when the number of alternative audio streams has changed.
	 * 
	 * @eventType org.osmf.events.AlternativeAudioEvent.NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE
	 *  
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.6
	 */
	[Event(name="numAlternativeAudioStreamsChange",type="org.osmf.events.AlternativeAudioEvent")]
	
	/**
	 * Dispatched when the <code>buffering</code> property has changed.
	 * 
	 * @eventType org.osmf.events.BufferEvent.BUFFERING_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="bufferingChange", type="org.osmf.events.BufferEvent")]
	
	/**
	 * Dispatched when the <code>bufferTime</code> property has changed.
	 * 
	 * @eventType org.osmf.events.BufferEvent.BUFFER_TIME_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="bufferTimeChange", type="org.osmf.events.BufferEvent")]

	/**
	 * Dispatched when the <code>bytesTotal</code> property has changed.
	 *
	 * @eventType org.osmf.events.LoadEvent
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="bytesTotalChange",type="org.osmf.events.LoadEvent")]
	
	/**
	 * Dispatched when the state of the LoadTrait has changed.
	 *
	 * @eventType org.osmf.events.LoadEvent.LOAD_STATE_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="loadStateChange", type="org.osmf.events.LoadEvent")]

	/**
	 * Dispatched when the state of the DRMTrait has changed.
	 *
	 * @eventType org.osmf.events.DRMEvent.DRM_STATE_CHANGE
 	 *  
 	 *  @langversion 3.0
 	 *  @playerversion Flash 10.1
 	 *  @playerversion AIR 1.5
 	 *  @productversion OSMF 1.0
 	 */ 
	[Event(name="drmStateChange", type="org.osmf.events.DRMEvent")]
	
	/**
	 * Dispatched when the <code>isRecording</code> property has changed.
	 * 
	 * @eventType org.osmf.events.DVREvent.IS_RECORDING_CHANGE
 	 *  
 	 *  @langversion 3.0
 	 *  @playerversion Flash 10.1
 	 *  @playerversion AIR 1.5
 	 *  @productversion OSMF 1.0
 	 */ 
	[Event(name="isRecordingChange", type="org.osmf.events.DVREvent")]
		
	/**
	 * TraitEventDispatcher is a utility class that exposes a uniform
	 * interface for receiving trait events from a MediaElement.  This
	 * class monitors the MediaElement for traits being added and
	 * removed, and dispatches any events that the MediaElement's traits
	 * dispatch, and for which the client has registered listeners.
	 * 
	 *  @includeExample TraitEventDispatcherExample.as -noswf 
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0	 
	 */ 
	public class TraitEventDispatcher extends EventDispatcher
	{
		/**
		 * Constructor.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0		 
		 */ 
		public function TraitEventDispatcher()
		{
			super();
			
			if (eventMaps == null)
			{
				eventMaps = new Dictionary();
				eventMaps[TimeEvent.DURATION_CHANGE]							= MediaTraitType.TIME;	
				eventMaps[TimeEvent.COMPLETE]									= MediaTraitType.TIME;	
				
				eventMaps[PlayEvent.PLAY_STATE_CHANGE]							= MediaTraitType.PLAY;	
				eventMaps[PlayEvent.CAN_PAUSE_CHANGE]							= MediaTraitType.PLAY;	
				
				eventMaps[AudioEvent.VOLUME_CHANGE]								= MediaTraitType.AUDIO;	
				eventMaps[AudioEvent.MUTED_CHANGE]								= MediaTraitType.AUDIO;
				eventMaps[AudioEvent.PAN_CHANGE]								= MediaTraitType.AUDIO;	
				
				eventMaps[SeekEvent.SEEKING_CHANGE]								= MediaTraitType.SEEK;	
				
				eventMaps[DynamicStreamEvent.SWITCHING_CHANGE] 					= MediaTraitType.DYNAMIC_STREAM;	
				eventMaps[DynamicStreamEvent.AUTO_SWITCH_CHANGE] 				= MediaTraitType.DYNAMIC_STREAM;	
				eventMaps[DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE] 		= MediaTraitType.DYNAMIC_STREAM;
				
				eventMaps[AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE] 			  	= MediaTraitType.ALTERNATIVE_AUDIO;	
				eventMaps[AlternativeAudioEvent.NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE] 	= MediaTraitType.ALTERNATIVE_AUDIO;
				
				eventMaps[DisplayObjectEvent.DISPLAY_OBJECT_CHANGE]				= MediaTraitType.DISPLAY_OBJECT;	
				eventMaps[DisplayObjectEvent.MEDIA_SIZE_CHANGE] 				= MediaTraitType.DISPLAY_OBJECT;	
				
				eventMaps[LoadEvent.LOAD_STATE_CHANGE]							= MediaTraitType.LOAD;	
				eventMaps[LoadEvent.BYTES_LOADED_CHANGE]						= MediaTraitType.LOAD;	
				eventMaps[LoadEvent.BYTES_TOTAL_CHANGE]							= MediaTraitType.LOAD;	
				
				eventMaps[BufferEvent.BUFFERING_CHANGE]							= MediaTraitType.BUFFER;
				eventMaps[BufferEvent.BUFFER_TIME_CHANGE]						= MediaTraitType.BUFFER;
				
				eventMaps[DRMEvent.DRM_STATE_CHANGE]							= MediaTraitType.DRM;
				eventMaps[DVREvent.IS_RECORDING_CHANGE]							= MediaTraitType.DVR;					
			}						
		}
		
		/**
		 * The MediaElement which will be monitored, and whose trait events
		 * will be redispatched.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0				 
		 */ 
		public function get media():MediaElement
		{
			return _mediaElement;
		}

		public function set media(value:MediaElement):void
		{
			if (value != _mediaElement)
			{
				var traitType:String;
				if (_mediaElement != null)
				{					
					_mediaElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
					_mediaElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
					
					for each (traitType in _mediaElement.traitTypes)
					{
						onTraitChanged(traitType, false);
					}								
				}	
				_mediaElement = value;
				if (_mediaElement != null)
				{
					_mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);					
					_mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
													
					for each (traitType in _mediaElement.traitTypes)
					{
						onTraitChanged(traitType, true);
					}
				}			
			}
		}
				
		/**
		 * @private
		 **/
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			var hadEventListener:Boolean = hasEventListener(type);		
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);			
			if (_mediaElement
				&& !hadEventListener
				&& eventMaps[type] != undefined)
			{				
				changeListeners(true, eventMaps[type], type);	
			}			
		}
		
		/**
		 * @private
		 **/
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			super.removeEventListener(type, listener, useCapture);
			if (_mediaElement 
				&& !hasEventListener(type) 
				&& eventMaps[type] != undefined)
			{		
				changeListeners(false, eventMaps[type], type);		
			}			
		}
		
		private function onTraitAdd(event:MediaElementEvent):void
		{				
			onTraitChanged(event.traitType, true);				
		}
		
		private function onTraitRemove(event:MediaElementEvent):void
		{
			onTraitChanged(event.traitType, false);						
		}
		
		private function onTraitChanged(traitType:String, add:Boolean):void
		{				
			switch (traitType)
			{
				case MediaTraitType.TIME:
					changeListeners(add, traitType, TimeEvent.DURATION_CHANGE);							
					changeListeners(add, traitType, TimeEvent.COMPLETE );								
					break;
				case MediaTraitType.PLAY:						
					changeListeners(add, traitType, PlayEvent.PLAY_STATE_CHANGE );		
					changeListeners(add, traitType, PlayEvent.CAN_PAUSE_CHANGE );																	
					break;	
				case MediaTraitType.AUDIO:					
					changeListeners(add, traitType, AudioEvent.VOLUME_CHANGE);		
					changeListeners(add, traitType, AudioEvent.MUTED_CHANGE);
					changeListeners(add, traitType, AudioEvent.PAN_CHANGE);							
					break;
				case MediaTraitType.SEEK:
					changeListeners(add, traitType, SeekEvent.SEEKING_CHANGE);
					break;
				case MediaTraitType.DYNAMIC_STREAM:	
					changeListeners(add, traitType, DynamicStreamEvent.SWITCHING_CHANGE);
					changeListeners(add, traitType, DynamicStreamEvent.AUTO_SWITCH_CHANGE);
					changeListeners(add, traitType, DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE);
					break;
				case MediaTraitType.ALTERNATIVE_AUDIO:	
					changeListeners(add, traitType, AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE);
					changeListeners(add, traitType, AlternativeAudioEvent.NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE);
					break;
				case MediaTraitType.DISPLAY_OBJECT:					
					changeListeners(add, traitType, DisplayObjectEvent.DISPLAY_OBJECT_CHANGE);											
					changeListeners(add, traitType, DisplayObjectEvent.MEDIA_SIZE_CHANGE);
					break;	
				case MediaTraitType.LOAD:					
					changeListeners(add, traitType, LoadEvent.LOAD_STATE_CHANGE);
					changeListeners(add, traitType, LoadEvent.BYTES_TOTAL_CHANGE);		
					changeListeners(add, traitType, LoadEvent.BYTES_LOADED_CHANGE);				
					break;		
				case MediaTraitType.BUFFER:
					changeListeners(add, traitType, BufferEvent.BUFFERING_CHANGE);	
					changeListeners(add, traitType, BufferEvent.BUFFER_TIME_CHANGE);						
					break;	
				case MediaTraitType.DRM:
					changeListeners(add, traitType, DRMEvent.DRM_STATE_CHANGE);
					break;
				case MediaTraitType.DVR:
					changeListeners(add, traitType, DVREvent.IS_RECORDING_CHANGE);	
					break;				
			}		
		}
				
		// Add any number of listeners to the trait, using the given event name.
		private function changeListeners(add:Boolean, traitType:String, event:String):void
		{
			if (_mediaElement.getTrait(traitType) != null)
			{		
				if (add && hasEventListener(event))
				{						
					_mediaElement.getTrait(traitType).addEventListener(event, redispatchEvent);
				}
				else
				{												
					_mediaElement.getTrait(traitType).removeEventListener(event, redispatchEvent);
				}
			}			
		}
		
		// Event Listeners will redispatch all of the ChangeEvents that correspond to trait 
		// properties.  The hasEventListener prevents the event from being cloned.
		private function redispatchEvent(event:Event):void
		{
			dispatchEvent(event.clone());			
		}	
		
		private static var eventMaps:Dictionary;	
		private var _mediaElement:MediaElement;		
	}
}
