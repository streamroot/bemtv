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
	import org.osmf.events.SeekEvent;

	/**
	 * Dispatched when this trait begins or ends a seek operation.
	 * 
	 * @eventType org.osmf.events.SeekEvent.SEEKING_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="seekingChange",type="org.osmf.events.SeekEvent")]

	/**
	 * SeekTrait defines the trait interface for media that can be instructed
	 * to jump to a position in time.  It can also be used as the base class for a
	 * more specific SeekTrait subclass.
	 * 
	 * <p>Use the <code>MediaElement.hasTrait(MediaTraitType.SEEK)</code> method to query
	 * whether a media element has a trait of this type.
	 * If <code>hasTrait(MediaTraitType.SEEK)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.SEEK)</code> method
	 * to get an object that is guaranteed to be of this type.</p>
	 * 
	 * @see org.osmf.media.MediaElement
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class SeekTrait extends MediaTraitBase
	{
		/**
		 * Constructor.
		 * 
		 * @timeTrait The TimeTrait used by this SeekTrait.
		 **/
		public function SeekTrait(timeTrait:TimeTrait)
		{
			super(MediaTraitType.SEEK);
			
			_timeTrait = timeTrait;
		}
		
		/**
		 * Indicates whether the media is currently seeking.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public final function get seeking():Boolean
		{
			return _seeking;
		}
		
		/**
		 * Instructs the media to jump to the specified <code>time</code>.
		 * 
		 * If a seek is attempted, dispatches a seekingChange event.
		 * If <code>time</code> is non numerical or negative, does not attempt to seek. 
		 * 
		 * @param time Time to seek to in seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public final function seek(time:Number):void
		{
			if (canSeekTo(time))
			{
				setSeeking(true, time);
			}
		}
		
		/**
		 * Indicates whether the media is capable of seeking to the
		 * specified time.
		 *  
		 * @param time Time to seek to in seconds.
		 * @return Returns <code>true</code> if the media can seek to the specified time.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */				
		public function canSeekTo(time:Number):Boolean
		{
			// Validate that the time is in range.  Note that we return true
			// if the time is less than the duration *or* the current time.  The
			// latter is for the case where the media has no (NaN) duration, but
			// is still progressing.  Presumably it should be possible to seek
			// backwards.
			return _timeTrait 
				?	(	isNaN(time) == false
					&& 	time >= 0
					&&	(time <= _timeTrait.duration || time <= _timeTrait.currentTime)
					)
				: 	false;
		}
		
		// Internals
		//
		
		/**
		 * The TimeTrait used by this SeekTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected final function get timeTrait():TimeTrait
		{
			return _timeTrait;
		}
		
		protected final function set timeTrait(value:TimeTrait):void
		{
			_timeTrait = value;
		}
		
		/**
		 * Must be called by the implementing media on completing a seek.
		 * Calls the <code>seekingChangeStart()</code> and <code>seekingChangeEnd()</code>
		 * methods.
		 * 
		 * @param value New seeking value.
		 * @param time Position in seconds that the playhead was ultimately
		 * moved to.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setSeeking(value:Boolean, time:Number):void
		{
			seekingChangeStart(value, time);
					
			_seeking = value;
					
			seekingChangeEnd(time);
		}
		
		/**
         * Called immediately before the <code>seeking</code> property is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
         * @param time New <code>time</code> value representing the time that the playhead seeks to.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function seekingChangeStart(newSeeking:Boolean, time:Number):void
		{
		}
		
		/**
		 * Called just after the <code>seeking</code> property has changed.
		 * Dispatches the change event.
		 * 
		 * <p>Subclasses that override should call this method to
		 * dispatch the change event.</p>
		 * 
		 * @param time New <code>time</code> value representing the time that the playhead seeked to.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function seekingChangeEnd(time:Number):void
		{
			dispatchEvent
				( new SeekEvent
					( SeekEvent.SEEKING_CHANGE
					, false
					, false
					, seeking
					, time
					)
				);
		}
	
		private var _timeTrait:TimeTrait;
		private var _seeking:Boolean;
	}
}