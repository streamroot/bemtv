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
	import org.osmf.events.BufferEvent;

	/**
	 * Dispatched when the trait's <code>buffering</code> property has changed.
	 * 
	 * @eventType org.osmf.events.BufferEvent.BUFFERING_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="bufferingChange",type="org.osmf.events.BufferEvent")]
	
	/**
	 * Dispatched when the trait's <code>bufferTime</code> property has changed.
	 * 
	 * @eventType org.osmf.events.BufferEvent.BUFFER_TIME_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="bufferTimeChange",type="org.osmf.events.BufferEvent")]

	/**
	 * BufferTrait defines the trait interface for media that can use a data buffer.
	 * It can also be used as the base class for a specific BufferTrait subclass.
	 * 
	 * <p>Use the <code>MediaElement.hasTrait(MediaTraitType.BUFFER)</code> method to query
	 * whether a media element has this trait. 
	 * If <code>hasTrait(MediaTraitType.BUFFER)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.BUFFER)</code> method
	 * to get an object of this type.</p>
	 * 
	 * @see org.osmf.media.MediaElement 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class BufferTrait extends MediaTraitBase
	{
		// Public interface
		//
		
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function BufferTrait()
		{
			super(MediaTraitType.BUFFER);
		}

		/**
		 * Indicates whether the media is currently buffering.
		 * 
		 * <p>The default is <code>false</code>.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get buffering():Boolean
		{
			return _buffering;
		}
		
		/**
		 * The length of the content currently in the media's
		 * buffer in seconds. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get bufferLength():Number
		{
			return _bufferLength;
		}
		
		/**
		 * The desired length of the media's buffer in seconds.
		 * 
		 * <p>If the passed value is not numerical or negative, it
		 * is forced to zero.</p>
		 * 
		 * <p>The default is zero.</p> 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get bufferTime():Number
		{
			return _bufferTime;
		}

		public function set bufferTime(value:Number):void
		{
			// Coerce value into a positive:
			if (isNaN(value) || value < 0)
			{
				value = 0;
			}
			
			if (value != _bufferTime)
			{
				bufferTimeChangeStart(value);
					
				_bufferTime = value;
					
				bufferTimeChangeEnd(); 
			}
		}

		// Internals
		//
		
		/**
		 * Defines the value of the bufferLength property.
		 * 
		 * <p>This method fires a BufferLengthChangeEvent if the value's
		 * change persists.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setBufferLength(value:Number):void
		{
			if (value != _bufferLength)
			{
				bufferLengthChangeStart(value);
					
				_bufferLength = value;
					
				bufferLengthChangeEnd();
			}
		}
		
		/**
		 * Indicates whether the trait is in a buffering state. Dispatches
		 * a bufferingChange event if invocation results in the <code>buffering</code>
		 * property changing.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setBuffering(value:Boolean):void
		{
			if (value != _buffering)
			{
				bufferingChangeStart(value);
					
				_buffering = value;
					
				bufferingChangeEnd();
			}
		}
		
		/**
		 * Called immediately before the <code>buffering</code> value is changed.
		 * <p>Subclasses implement this method to communicate the change to the media.</p>
		 *
		 * @param newBuffering New <code>buffering</code> value. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function bufferingChangeStart(newBuffering:Boolean):void
		{
		}
		
		/**
		 * Called just after <code>buffering</code> has changed.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the bufferingChange event.</p> 
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function bufferingChangeEnd():void
		{
			dispatchEvent(new BufferEvent(BufferEvent.BUFFERING_CHANGE, false, false, _buffering));
		}
				
		/**
		 * Called immediately before the <code>bufferLength</code> value is changed. 
		 * Subclasses implement this method to communicate the change to the media.
		 * @param newSize New <code>bufferLength</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function bufferLengthChangeStart(newSize:Number):void
		{
		}
		
		/**
		 * Called just after the <code>bufferLength</code> value has changed.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function bufferLengthChangeEnd():void
		{	
		}
				
		/**
		 * Called immediately before the <code>bufferTime</code> value is changed.
		 * Subclasses implement this method to communicate the change to the media. 
		 *
		 * @param newTime New <code>bufferTime</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function bufferTimeChangeStart(newTime:Number):void
		{
		}
		
		/**
		 * Called just after the <code>bufferTime</code> value has changed.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the bufferTimeChange event.</p>
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function bufferTimeChangeEnd():void
		{
			dispatchEvent(new BufferEvent(BufferEvent.BUFFER_TIME_CHANGE, false, false, false, _bufferTime));	
		}

		private var _buffering:Boolean = false;
		private var _bufferLength:Number = 0;
		private var _bufferTime:Number = 0;
	}
}