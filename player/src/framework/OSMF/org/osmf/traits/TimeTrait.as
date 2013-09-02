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
	import org.osmf.events.TimeEvent;

	/**
	 * Dispatched when the duration of the trait changed.
	 * 
	 * @eventType org.osmf.events.TimeEvent.DURATION_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="durationChange", type="org.osmf.events.TimeEvent")]
	
	/**
	 * Dispatched when the currentTime of the trait has changed to a value
	 * equal to its duration.
	 * 
	 * @eventType org.osmf.events.TimeEvent.COMPLETE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="complete",type="org.osmf.events.TimeEvent")]
	
	/**
	 * TimeTrait defines the trait interface for media that have a duration and
	 * a currentTime.  It can also be used as the base class for a more specific
	 * TimeTrait subclass.
	 * 
	 * <p>Use the <code>MediaElement.hasTrait(MediaTraitType.TIME)</code> method to query
	 * whether a media element has a trait of this type.
	 * If <code>hasTrait(MediaTraitType.TIME)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.TIME)</code> method
	 * to get an object that is of this type.</p>
	 * 
	 * @see org.osmf.media.MediaElement
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class TimeTrait extends MediaTraitBase
	{
		/**
		 * Constructor.
		 * 
		 * @param duration The duration of the media, in seconds.  The default
		 * is NaN (no duration).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function TimeTrait(duration:Number=NaN)
		{
			super(MediaTraitType.TIME);
			
			_duration = duration;
		}

		/**
		 * The duration of the media, in seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get duration():Number
		{
			return _duration;
		}
		
		/**
		 * The current time of the media, in seconds.  Must never
		 * exceed the <code>duration</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get currentTime():Number
		{
			return _currentTime;
		}
		
		// Internals
		//
		
		/**
		 * Called immediately before the <code>duration</code> property is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
		 *  
		 * @param newDuration New <code>duration</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function durationChangeStart(newDuration:Number):void
		{
		}
		
		/**
		 * Called just after the <code>duration</code> property has changed.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method to
		 * dispatch the durationChange event.</p>
		 *  
		 * @param oldDuration Previous <code>duration</code> value.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function durationChangeEnd(oldDuration:Number):void
		{
			dispatchEvent(new TimeEvent(TimeEvent.DURATION_CHANGE, false, false, _duration));
		}

		/**
		 * Called immediately before the <code>currentTime</code> property is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
		 * @param newCurrentTime New <code>currentTime</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function currentTimeChangeStart(newCurrentTime:Number):void
		{
		}
		
		/**
		 * Called just after the <code>currentTime</code> property has changed.
		 * @param oldCurrentTime Previous <code>currentTime</code> value.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function currentTimeChangeEnd(oldCurrentTime:Number):void
		{
		}
		
		/**
		 * @private
		 * 
		 * Called when a subclass or a media element that has the temporal trait first detects
		 * that <code>currentTime</code> equals <code>duration</code>.
		 * <p>Not called when both <code>currentTime</code> and <code>duration</code> equal zero.</p>
		 * 
		 * <p>Dispatches the complete event.</p>
		 * 
		 * <p>Exposed as protected (though undocumented) because some subclasses need to
		 * prevent event dispatch.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function signalComplete():void
		{
			dispatchEvent(new TimeEvent(TimeEvent.COMPLETE));
		}

		/**
		 * Invoking this setter will result in the trait's currentTime
		 * value changing if it differs from currentTime's current value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setCurrentTime(value:Number):void
		{
			if (!isNaN(value))
			{
				// Don't ever let the currentTime exceed the duration.
				if (!isNaN(_duration))
				{
					value = Math.min(value, _duration);
				}
				else
				{
					value = 0;
				}
			}
			
			if (	_currentTime != value
				&& 	!
						(	isNaN(_currentTime)
						&& 	isNaN(value)
						)
				)
			{
				currentTimeChangeStart(value);
					
				var oldCurrentTime:Number = _currentTime;
				_currentTime = value;
				
				currentTimeChangeEnd(oldCurrentTime);
				
				if (currentTime == duration && currentTime > 0)
				{
					signalComplete();
				} 
			}
		}
		
		/**
		 * Invoking this setter will result in the trait's duration
		 * value changing if it differs from duration's current value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setDuration(value:Number):void
		{
			if (_duration != value)
			{
				durationChangeStart(value);
			
				var oldDuration:Number = _duration;
				_duration = value;
				
				durationChangeEnd(oldDuration);
				
				// Current time cannot exceed duration.
				if (	!isNaN(_currentTime)
					&&  !isNaN(_duration)
					&& _currentTime > _duration
				   )
				{
					setCurrentTime(duration);
				}
			}
		}
		
		private var _duration:Number;
		private var _currentTime:Number;
	}
}