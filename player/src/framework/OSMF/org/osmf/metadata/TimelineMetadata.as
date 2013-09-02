/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.metadata
{
	import __AS3__.vec.Vector;
	
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MetadataEvent;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimelineMetadataEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * Dispatched when a TimelineMarker is added to this object.
	 *
	 * @eventType org.osmf.events.TimelineMetadataEvent.MARKER_ADD
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event (name="markerAdd", type="org.osmf.events.TimelineMetadataEvent")]

	/**
	 * Dispatched when a TimelineMarker is removed from this object.
	 *
	 * @eventType org.osmf.events.TimelineMetadataEvent.MARKER_REMOVE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event (name="markerRemove", type="org.osmf.events.TimelineMetadataEvent")]

	/**
	 * Dispatched when the currentTime property of the MediaElement associated
	 * with this TimelineMetadata has reached the time value of one of the
	 * TimelineMarkers in this TimelineMetadata.
	 *
	 * @eventType org.osmf.events.TimelineMetadataEvent.MARKER_TIME_REACHED
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event (name="markerTimeReached", type="org.osmf.events.TimelineMetadataEvent")]

	/**
	 * Dispatched when the currentTime property of the MediaElement associated
	 * with this TimelineMetadata has reached the duration offset of one of the
	 * TimelineMarkers in this TimelineMetadata.
	 *
	 * @eventType org.osmf.events.TimelineMetadataEvent.MARKER_TIME_REACHED
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event (name="markerDurationReached", type="org.osmf.events.TimelineMetadataEvent")]

	/**
	 * The TimelineMetadata class encapsulates metadata associated with the
	 * timeline of a MediaElement.
	 * 
	 * <p>TimelineMetadata uses the TimelineMarker class to represent both
	 * keys and values (i.e. a TimelineMarker will be stored as both key and
	 * value).  A TimelineMetadata object dispatches a TimelineMetadataEvent
	 * when the currentTime property of the MediaElement's TimeTrait matches
	 * any of the time values in its collection of TimelineMarker objects.</p>
	 * 
	 *  @includeExample TimelineMetadataExample.as -noswf
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class TimelineMetadata extends Metadata
	{
		/**
		 * Constructor.
		 * 
		 * @param media The media element this timeline metadata applies to.
		 * 
		 * @throws ArgumentError If the media argument is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function TimelineMetadata(media:MediaElement)
		{
			super();

			if (media == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}

			this.media = media;	
			_enabled = true;
			
			intervalTimer = new Timer(CHECK_INTERVAL);
			intervalTimer.addEventListener(TimerEvent.TIMER, onIntervalTimer);
			
			// Check the media element for traits, if they are null here
			// that's okay we'll manage them in the event handlers.
			timeTrait = media.getTrait(MediaTraitType.TIME) as TimeTrait;
			
			seekTrait = media.getTrait(MediaTraitType.SEEK) as SeekTrait;
			setupTraitEventListener(MediaTraitType.SEEK);
			
			playTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
			setupTraitEventListener(MediaTraitType.PLAY);
			
			media.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
			media.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
		}
		
		/**
		 * The number of TimelineMarker objects contained within this object.
		 **/
		public function get numMarkers():int
		{
			return temporalValueCollection ? temporalValueCollection.length : 0;
		}
		
		/**
		 * Returns the TimelineMarker at the specified index.  Note that the
		 * markers are sorted by time.
		 *  
		 * @param index The index of the marker to return.
		 * 
		 * @returns The marker at that index, null if there is no
		 * such marker at that index.
		 **/
		public function getMarkerAt(index:int):TimelineMarker
		{
			if (index >= 0 && temporalValueCollection != null && index < temporalValueCollection.length)
			{
				return temporalValueCollection[index];
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * Adds the specified TimelineMarker to this object.  This class
		 * maintains the TimelineMarkers in time order.  If another TimelineMarker
		 * with the same time value exists within this object, then the existing
		 * value will be overwritten.
		 * 
		 * @param marker The marker to add.
		 * 
		 * @throws ArgumentError If marker is null or specifies an invalid time.
		 **/
		public function addMarker(marker:TimelineMarker):void
		{
			if (marker == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}

			addValue("" + marker.time, marker);
		}
		
		/**
		 * Removes the specified TimelineMarker from this object.
		 * 
		 * @param marker The marker to remove.
		 * 
		 * @returns The removed marker, null if the specified marker is not
		 * contained within this object.
		 * 
		 * @throws ArgumentError If marker is null.
		 **/
		public function removeMarker(marker:TimelineMarker):TimelineMarker
		{
			if (marker == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}

			return removeValue("" + marker.time);
		}
		
		/**
		 * @private
		 */
		override public function addValue(key:String, value:Object):void
		{
			var time:Number = new Number(key);
			var marker:TimelineMarker = value as TimelineMarker;
			
			if (key == null || isNaN(time) || time < 0 || marker == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			if (temporalValueCollection == null)
			{
				temporalKeyCollection = new Vector.<Number>();
				temporalKeyCollection.push(time);

				temporalValueCollection = new Vector.<TimelineMarker>();
				temporalValueCollection.push(value);
			}
			else
			{
				// Find the index where we should insert this value
				var index:int = findTemporalMetadata(0, temporalValueCollection.length - 1, time);
				
				// A negative index value means it doesn't exist in the array and the absolute value is the
				// index where it should be inserted.  A positive index means a value exists and in this
				// case we'll overwrite the existing value rather than insert a duplicate.
				if (index < 0) 
				{
					index *= -1;
					temporalKeyCollection.splice(index, 0, time);
					temporalValueCollection.splice(index, 0, marker);
				}
				
				// Make sure we don't insert a dup at index 0
				else if ((index == 0) && (time != temporalKeyCollection[0])) 
				{
					temporalKeyCollection.splice(index, 0, time);
					temporalValueCollection.splice(index, 0, marker);
				}
				else 
				{
					temporalKeyCollection[index] = time;
					temporalValueCollection[index] = marker;
				}
			}
			
			enabled = true;
			
			dispatchEvent(new MetadataEvent(MetadataEvent.VALUE_ADD, false, false, key, marker));
			dispatchEvent(new TimelineMetadataEvent(TimelineMetadataEvent.MARKER_ADD, false, false, marker));
		}
		
		/**
		 * @private
		 **/
		override public function removeValue(key:String):*
		{
			if (key == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}

			var time:Number = new Number(key);
			
			var result:* = null;
			
			// Also remove from our collections.
			var index:int = temporalValueCollection ? findTemporalMetadata(0, temporalValueCollection.length - 1, time) : -1;
			if (index >= 0)
			{
				temporalKeyCollection.splice(index, 1);
				result = temporalValueCollection.splice(index, 1)[0];
				
				// If we just removed the last one, clean up and stop the interval timer (fix for FM-1052)
				if (temporalValueCollection.length == 0)
				{
					reset(false);
					temporalValueCollection = null;
					temporalKeyCollection = null;
				}
				
				dispatchEvent(new MetadataEvent(MetadataEvent.VALUE_REMOVE, false, false, key, result));
				dispatchEvent(new TimelineMetadataEvent(TimelineMetadataEvent.MARKER_REMOVE, false, false, result as TimelineMarker));
			}
			
			return result;
		}
		
		/**
		 * @private
		 */
		override public function getValue(key:String):*
		{
			if (key == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}

			var time:Number = new Number(key);
			if (!isNaN(time))
			{
				for (var i:int = 0; i < temporalKeyCollection.length; i++)
				{
					var keyTime:Number = temporalKeyCollection[i];
					if (keyTime == time)
					{
						return temporalValueCollection[i];
					}
				}
			}
			
			return null;
		}
		
		/**
		 * @private
		 * 
		 * Enables/disables this metadata object (enabled by default). If enabled, the
		 * class will dispatch events of type TimelineMetadataEvent. Setting
		 * this property to <code>false</code> will cause the class to stop
		 * dispatching events.
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
		 **/ 
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
			reset(value);
		}
		
		/**
		 * Starts / stops the interval timer.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function startTimer(start:Boolean=true):void
		{
			if (!start)
			{
				intervalTimer.stop();
			}
			else if (	timeTrait != null
					 && temporalValueCollection != null
					 && temporalValueCollection.length > 0 
					 && restartTimer
					 && enabled
					 && !intervalTimer.running
					) 
			{
				// If there is a PlayTrait and the media isn't playing, there is no reason to 
				// start the timer.
				if (playTrait != null && playTrait.playState == PlayState.PLAYING)
				{
					intervalTimer.start();
				}
			}
		}
						
		/**
		 * Perform a reset on the class' internal state.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function reset(startTimer:Boolean):void 
		{
			lastFiredTemporalMetadataIndex = -1;
			restartTimer = true;
			intervalTimer.reset();
			intervalTimer.delay = CHECK_INTERVAL;
			
			if (startTimer)
			{
				this.startTimer();
			}
		}
		
		/**
		 * The interval timer callback. Checks for temporal metadata 
		 * around the current TimeTrait.currentTime and dispatches an event
		 * if found. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
   		private function checkForTemporalMetadata():void 
   		{
			var now:Number = timeTrait.currentTime;
			
			// Start looking one index past the last one we found
			var index:int = findTemporalMetadata(lastFiredTemporalMetadataIndex + 1, temporalValueCollection.length - 1, now);
			
			// A negative index value means it doesn't exist in the collection and the absolute value is the
			// index where it should be inserted.  Therefore, to get the closest match, we'll look at the index
			// before this one.  A positive index means an exact match was found.
			if (index <= 0) 
			{
				index *= -1;
				index = (index > 0) ? (index - 1) : 0;
			}
			
			// See if the value at this index is within our tolerance
			if (!checkTemporalMetadata(index, now) && ((index + 1) < temporalValueCollection.length)) 
			{
				// Look at the next one, see if it is close enough to fire
				checkTemporalMetadata(index+1, now);
			}
   		}
   		
   		private function setupTraitEventListener(traitType:String, add:Boolean=true):void
   		{
   			if (add)
   			{
	   			if (traitType == MediaTraitType.SEEK && seekTrait != null)
	   			{
					seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
	   			}
	   			
	   			else if (traitType == MediaTraitType.PLAY && playTrait != null)
	   			{
	   				playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
	   				
	   				// We need to check the playing state, if the media is already playing, we won't 
	   				// get the play state change event and the interval timer will never start.
	   				if (playTrait.playState == PlayState.PLAYING)
	   				{
	   					var event:PlayEvent = new PlayEvent(PlayEvent.PLAY_STATE_CHANGE, false, false, PlayState.PLAYING);
	   					onPlayStateChange(event);
	   				}
	   			}
	   		}
	   		else
	   		{
	   			if (traitType == MediaTraitType.SEEK && seekTrait != null)
	   			{
					seekTrait.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
	   			}
	   			
	   			else if (traitType == MediaTraitType.PLAY && playTrait != null)
	   			{
	   				playTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
	   			}
	   		}
   		}
   		
   		private function onSeekingChange(event:SeekEvent):void
   		{
   			if (event.seeking)
   			{
   				reset(true);
   			}
   		}
   		
   		private function onPlayStateChange(event:PlayEvent):void
   		{
   			var timer:Timer;
   			if (event.playState == PlayState.PLAYING)
   			{
   				// Start any duration timers.
   				if (durationTimers != null)
   				{
   					for each (timer in durationTimers)
   					{
   						timer.start();
   					}
   				}
   				startTimer();
   			}
   			else
   			{
  				// Pause any duration timers.
   				if (durationTimers != null)
   				{
   					for each (timer in durationTimers)
   					{
   						timer.stop();
   					}
   				}
 
   				startTimer(false);
   			}
   		}
   		
		/**
		 * Returns the index of the temporal metadata object matching the time. If no match is found, returns
		 * the index where the value should be inserted as a negative number.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function findTemporalMetadata(firstIndex:int, lastIndex:int, time:Number):int 
		{
			if (firstIndex <= lastIndex) 
			{
				var mid:int = (firstIndex + lastIndex) / 2;	// divide and conquer
				if (time == temporalKeyCollection[mid]) 
				{
					return mid;
				}
				else if (time < temporalKeyCollection[mid]) 
				{
					// search the lower part
					return findTemporalMetadata(firstIndex, mid - 1, time);
				}
				else 
				{
					// search the upper part
					return findTemporalMetadata(mid + 1, lastIndex, time);
				}
			}
			return -(firstIndex);
		}   		
		
		/**
		 * Dispatch the events for this temporal value. If there is a duration
		 * property on the value, dispatch a duration reached event after the 
		 * proper amount of time has passed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function dispatchTemporalEvents(index:int):void
		{
			var marker:TimelineMarker = temporalValueCollection[index];
			dispatchEvent(new TimelineMetadataEvent(TimelineMetadataEvent.MARKER_TIME_REACHED, false, false, marker));
			
			if (marker.duration > 0)
			{
				var timer:Timer = new Timer(CHECK_INTERVAL);
				var endTime:Number = marker.time + marker.duration;
				
				// Add it to the dictionary of duration timers so we can pause it 
				// if the media pauses.
				if (durationTimers == null)
				{
					durationTimers = new Dictionary();
				}
				durationTimers[marker] = timer;

				timer.addEventListener(TimerEvent.TIMER, onDurationTimer);
				timer.start();
				
				function onDurationTimer(event:TimerEvent):void
				{
					if (timeTrait && timeTrait.currentTime >= endTime)
					{
						timer.removeEventListener(TimerEvent.TIMER, onDurationTimer);
						delete durationTimers[marker];
						dispatchEvent(new TimelineMetadataEvent(TimelineMetadataEvent.MARKER_DURATION_REACHED, false, false, marker));
					}
				}
			}
		}
		
   		/**
   		 * Checks the item at the index passed in with the time passed in.
   		 * If the item time is within the class' tolerance, an event is dispatched.
   		 * 
   		 * Returns True if a match was found, otherwise False.
   		 *  
   		 *  @langversion 3.0
   		 *  @playerversion Flash 10
   		 *  @playerversion AIR 1.5
   		 *  @productversion OSMF 1.0
   		 */
   		private function checkTemporalMetadata(index:int, now:Number):Boolean 
   		{ 		
			if (!temporalValueCollection || !temporalValueCollection.length) 
			{
				return false;
			}
			
			var result:Boolean = false;																				
		
			if ( 	(temporalValueCollection[index].time >= (now - TOLERANCE))
				&& 	(temporalValueCollection[index].time <= (now + TOLERANCE))
				&&	(index != lastFiredTemporalMetadataIndex)
			   ) 
			{
				lastFiredTemporalMetadataIndex = index;
				
				dispatchTemporalEvents(index);
				
				// Adjust the timer interval if necessary
				var thisTime:Number = temporalKeyCollection[index];
				// Get the next time value after this one so we can decide to adjust the timer interval
				var nextTime:Number = calcNextTime(index);
				
				var newDelay:Number = ((nextTime - thisTime)*1000)/4;
				newDelay = (newDelay > CHECK_INTERVAL) ? newDelay : CHECK_INTERVAL;
								
				// If no more data, stop the timer
				if (thisTime == nextTime) 
				{
					startTimer(false);
					restartTimer = false;
				}
				else if (newDelay != intervalTimer.delay) 
				{
					intervalTimer.reset();
					intervalTimer.delay = newDelay;
					startTimer();
				}
				result = true;
			}
			
			// If we've optimized the interval time by reseting the delay, we could miss a data point
			//    if it happens to fall between this check and next one.
			// See if we are going to miss a data point (meaning there is one between now and the 
			//    next interval timer event).  If so, drop back down to the default check interval.
			else if ((intervalTimer.delay != CHECK_INTERVAL) && ((now + (intervalTimer.delay/1000)) > calcNextTime(index))) 
			{
				this.intervalTimer.reset();
				this.intervalTimer.delay = CHECK_INTERVAL;
				startTimer();
			}
			return result;				
   		}		

		private function calcNextTime(index:int):Number
		{
			return temporalValueCollection [ index + 1 < temporalKeyCollection.length
										  	 ? index + 1
					  		  				 : temporalKeyCollection.length - 1
					 						].time;
		}
		
		/**
		 * The interval timer event handler.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function onIntervalTimer(event:TimerEvent):void 
		{
			checkForTemporalMetadata();
		}
		
		/**
		 * Called when traits are added to the media element.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function onTraitAdd(event:MediaElementEvent):void
		{
			switch (event.traitType)
			{
				case MediaTraitType.TIME:
					timeTrait = media.getTrait(MediaTraitType.TIME) as TimeTrait;
					startTimer();
					break;
				case MediaTraitType.SEEK:
					seekTrait = media.getTrait(MediaTraitType.SEEK) as SeekTrait;
					break;
				case MediaTraitType.PLAY:
					playTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
					break;
			}
			
			setupTraitEventListener(event.traitType);
		}
		
		/**
		 * Called when traits are removed from the media element.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function onTraitRemove(event:MediaElementEvent):void
		{
			// Remove any event listeners
			setupTraitEventListener(event.traitType, false);

			switch (event.traitType)
			{
				case MediaTraitType.TIME:
					timeTrait = null;
					// This is a work around for FM-171. Traits are added and removed for
					// each child in a composition element when transitioning between child
					// elements. So don't stop the timer if the MediaElement is a composition
					// (which we determine by looking for the numChildren property, since
					// we don't want to link the composition classes in by default).
					if (media.hasOwnProperty("numChildren") == false)
					{
						startTimer(false);
					}
					break;
				case MediaTraitType.SEEK:
					seekTrait = null;
					break;
				case MediaTraitType.PLAY:
					playTrait = null;
					break;
			}
		}
			
		private static const CHECK_INTERVAL:Number = 100;	// The default interval (in milliseconds) the 
															// class will check for temporal metadata
		private static const TOLERANCE:Number = 0.25;	// A value must be within this tolerence to trigger
														//	a timeReached event.				
		private var temporalKeyCollection:Vector.<Number>;
		private var temporalValueCollection:Vector.<TimelineMarker>;
		private var media:MediaElement;
		private var timeTrait:TimeTrait;
		private var seekTrait:SeekTrait;
		private var playTrait:PlayTrait;
		private var lastFiredTemporalMetadataIndex:int;
		private var intervalTimer:Timer;
		private var restartTimer:Boolean;
		private var _enabled:Boolean;
		private var durationTimers:Dictionary;
	}
}
