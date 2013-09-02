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
*  Contributor(s): Adobe Systems Incorporated.
* 
*****************************************************/
package org.osmf.traits
{
	import flash.errors.IllegalOperationError;
	
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * Dispatched when a stream switch is requested, completed, or failed.
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
	 * Dispatched when the autoSwitch property changed.
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
	 * DynamicStreamTrait defines the trait interface for media supporting dynamic stream
	 * switching.  It can also be used as the base class for a more specific DynamicStreamTrait
	 * subclass.
	 * 
	 * <p>Use the <code>MediaElement.hasTrait(MediaTraitType.DYNAMIC_STREAM)</code> method to query
	 * whether a media element has a trait of this type.
	 * If <code>hasTrait(MediaTraitType.DYNAMIC_STREAM)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.DYNAMIC_STREAM)</code> method
	 * to get an object of this type.</p>
	 * 
	 * @see org.osmf.media.MediaElement
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class DynamicStreamTrait extends MediaTraitBase
	{
		/**
		 * Constructor.
		 * 
		 * @param autoSwitch The initial autoSwitch state for the trait.  The default is true.
		 * @param currentIndex The initial stream index for the trait.  The default is zero.
		 * @param numDynamicStreams The total number of dynamic streams.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function DynamicStreamTrait(autoSwitch:Boolean=true, currentIndex:int=0, numDynamicStreams:int=1)
		{
			super(MediaTraitType.DYNAMIC_STREAM);
			
			_autoSwitch = autoSwitch;
			_currentIndex = currentIndex;		
			_numDynamicStreams = numDynamicStreams;
			_maxAllowedIndex = numDynamicStreams - 1;

			_switching = false;
		}
		
		/**
		 * Defines whether or not the trait should be in manual 
		 * or auto-switch mode. If in manual mode the <code>switchTo</code>
		 * method can be used to manually switch to a specific stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get autoSwitch():Boolean
		{			
			return _autoSwitch;
		}
		
		public final function set autoSwitch(value:Boolean):void
		{
			if (autoSwitch != value)
			{
				autoSwitchChangeStart(value);

				_autoSwitch = value;
				
				autoSwitchChangeEnd();
			}
		}
		
		/**
		 * The total number of dynamic streams.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get numDynamicStreams():int
		{
			return _numDynamicStreams;
		}

		/**
		 * The index of the current dynamic stream.  Uses a zero-based index.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get currentIndex():int
		{
			return _currentIndex;
		}

		/**
		 * The maximum allowed index. This can be set at run-time to 
		 * provide a ceiling for the switching profile, for example,
		 * to keep from switching up to a higher quality stream when 
		 * the current video is too small to handle a higher quality stream.
		 * 
		 * The default is the highest stream index.
		 * 
		 * @throws RangeError If the specified index is less than zero or
		 * greater than the total number of dynamic streams.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get maxAllowedIndex():int
		{
			return _maxAllowedIndex;
		}
		
		public final function set maxAllowedIndex(value:int):void
		{
			if (value < 0 || value > _numDynamicStreams - 1)
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
			}

			if (maxAllowedIndex != value)
			{
				maxAllowedIndexChangeStart(value);

				_maxAllowedIndex = value;
				
				maxAllowedIndexChangeEnd();
			}		
		}
		
		/**
		 * Returns the associated bitrate, in kilobits per second, for the specified index.
		 * 
		 * @throws RangeError If the specified index is less than zero or
		 * greater than the highest index available.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function getBitrateForIndex(index:int):Number
		{
			if (index > _numDynamicStreams - 1 || index < 0)
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
			}
			
			return 0;
		}

		/**
		 * Indicates whether or not a switch is currently in progress.
		 * This property will return <code>true</code> while a switch has been 
		 * requested and the switch has not yet been acknowledged and no switch failure 
		 * has occurred.  Once the switch request has been acknowledged or a 
		 * failure occurs, the property will return <code>false</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get switching():Boolean
		{			
			return _switching;
		}
		
		/**
		 * Switch to a specific index. To switch up, use the <code>currentIndex</code>
		 * property, such as:<p>
		 * <code>
		 * obj.switchTo(obj.currentIndex + 1);
		 * </code>
		 * </p>
		 * @throws RangeError If the specified index is less than zero or
		 * greater than <code>maxAllowedIndex</code>.
    	 * Note:  If the media is paused, switching will not take place until after play resumes.		 
		 * @throws IllegalOperationError If the stream is not in manual switch mode.
		 * 
		 * @see maxAllowedIndex
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function switchTo(index:int):void
		{
			if (autoSwitch)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_STREAM_NOT_IN_MANUAL_MODE));
			}
			else if (index != currentIndex)
			{
				if (index < 0 || index > maxAllowedIndex)
				{
					throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
				}

				// This method sets the switching state to true.  The processing
				// and completion of the switch are up to the implementing media.
				setSwitching(true, index);
			}			
		}
				
		// Internals
		//

		/**
		 * Invoking this setter will result in the trait's numDynamicStreams
		 * property changing.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setNumDynamicStreams(value:int):void
		{
			if (value != _numDynamicStreams)
			{
				_numDynamicStreams = value;
				
				// Only adjust our maxAllowedIndex property if the old value
				// is now out of range.
				if (maxAllowedIndex >= _numDynamicStreams)
				{
					maxAllowedIndex = Math.max(0, _numDynamicStreams - 1);
				}
				
				dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE));
			}			
		}
		
		/**
		 * Invoking this setter will result in the trait's currentIndex
		 * property changing.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setCurrentIndex(value:int):void
		{
			_currentIndex = value;
		}
		
		/**
		 * Must be called by the implementing media on completing a switch.
		 * 
		 * Calls the <code>switchingChangeStart()</code> and <code>switchingChangeEnd()</code>
		 * methods.
		 * @param newSwitching New <code>switching</code> value for the trait.
		 * @param index The index to which the switch shall (or did) occur.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setSwitching(newSwitching:Boolean, index:int):void
		{
			if (newSwitching != _switching)
			{
				switchingChangeStart(newSwitching, index);
				
				_switching = newSwitching;
				
				// Update the index when a switch finishes.
				if (newSwitching == false)
				{
					setCurrentIndex(index);
				}
				
				switchingChangeEnd(index);
			}
		}

		/**
         * Called immediately before the <code>autoSwitch</code> property is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
         * @param value New value for the <code>autoSwitch</code> property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function autoSwitchChangeStart(value:Boolean):void
		{			
		}
				
		/**
		 * Called just after the <code>autoSwitch</code> property has changed.
		 * Dispatches the change event.
		 * 
		 * <p>Subclasses that override should call this method to
		 * dispatch the change event.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function autoSwitchChangeEnd():void
		{
			dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.AUTO_SWITCH_CHANGE, false, false, false, _autoSwitch));	
		}
		
		/**
		 * Called immediately before the <code>switching</code> property is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
         * @param newSwitching New value for the <code>switching</code> property.
         * @param index The index of the stream to switch to.
 		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function switchingChangeStart(newSwitching:Boolean, index:int):void
		{			
		}
		
		/**
		 * Called just after the <code>switching</code> property has changed.
		 * Dispatches the change event.
		 * 
		 * <p>Subclasses that override should call this method to
		 * dispatch the change event.</p>
		 * 
		 * @param index The index of the switched-to stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function switchingChangeEnd(index:int):void
		{
			dispatchEvent
				( new DynamicStreamEvent
					( DynamicStreamEvent.SWITCHING_CHANGE
					, false
					, false
					, switching
					)
				);
		}
		
		/**
		 * Called immediately before the <code>maxAllowedIndex</code> property is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
         * @param newIndex New value for the <code>maxAllowedIndex</code> property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function maxAllowedIndexChangeStart(newIndex:int):void
		{			
		}
		
		/**
		 * Called just after the <code>maxAllowedIndex</code> property has changed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function maxAllowedIndexChangeEnd():void
		{
		}
		
		private var _autoSwitch:Boolean;
		private var _currentIndex:int = 0;
		private var _maxAllowedIndex:int = 0;
		private var _numDynamicStreams:int;
		private var _switching:Boolean;
	}
}
