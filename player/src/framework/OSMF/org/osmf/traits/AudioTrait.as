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
	import org.osmf.events.AudioEvent;
	
	/**
	 * Dispatched when the trait's <code>volume</code> property has changed.
	 * 
	 * @eventType org.osmf.events.AudioEvent.VOLUME_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="volumeChange",type="org.osmf.events.AudioEvent")]
	
	/**
  	 * Dispatched when the trait's <code>muted</code> property has changed.
  	 * 
  	 * @eventType org.osmf.events.AudioEvent.MUTED_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="mutedChange",type="org.osmf.events.AudioEvent")]
	
	/**
 	 * Dispatched when the trait's <code>pan</code> property has changed.
 	 * 
 	 * @eventType org.osmf.events.AudioEvent.PAN_CHANGE 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="panChange",type="org.osmf.events.AudioEvent")]
	
	/**
	 * AudioTrait defines the trait interface for media that have audio.  It
	 * can also be used as the base class for a specific AudioTrait class.
	 * 
	 * <p>Use the <code>MediaElement.hasTrait(MediaTraitType.AUDIO_TRAIT)</code> method to query
	 * whether a media element has this trait. 
	 * If <code>hasTrait(MediaTraitType.AUDIO_TRAIT)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.AUDIO_TRAIT)</code> method
	 * to get an object of this type.</p>
	 * 
	 * @see org.osmf.media.MediaElement
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class AudioTrait extends MediaTraitBase
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function AudioTrait()
		{
			super(MediaTraitType.AUDIO);
		}
		
		/**
		 * The volume, ranging from 0 (silent) to 1 (full volume).
		 * 
		 * <p>Passing a value greater than 1 sets the value to 1.
		 * Passing a value less than zero sets the value to zero.
		 * </p>
		 * 
		 * <p>Changing the value of the <code>volume</code> property does not affect the value of the
		 * <code>muted</code> property.</p>
		 * 
		 * <p>The default is 1.</p>
		 * 
		 * @see AudioTrait#muted 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get volume():Number
		{
			return _volume;
		}
		
		public final function set volume(value:Number):void
		{
			// Coerce the value into our range:
			if (isNaN(value))
			{
				value = 0;
			}
			else if (value > 1)
			{
				value = 1;
			}
			else if (value < 0)
			{
				value = 0;
			}
			
			if (value != _volume)
			{
				volumeChangeStart(value);
				
				_volume = value;
				
				volumeChangeEnd();
			}
		}
		
		/**
		 * Indicates whether the AudioTrait is muted or sounding. 
		 * 
		 * <p>Changing the value of the <code>muted</code> property does not affect the 
		 * value of the <code>volume</code> property.</p>
		 * 
		 * <p>The default value is <code>false</code>.</p>
		 * 
		 * @see AudioTrait#volume
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get muted():Boolean
		{
			return _muted;
		}
		
		public final function set muted(value:Boolean):void
		{
			if (value != _muted)
			{
				mutedChangeStart(value);
				
				_muted = value;
				
				mutedChangeEnd();
			}
		}
		
		/**
		 * The left-to-right panning of the sound. Ranges from -1
		 * (full pan left) to 1 (full pan right).
		 * 
		 * <p>Passing a value greater than 1 sets the value to 1.
		 * Passing a value less than -1 sets the value to -1.
		 * </p>
		 * 
		 * <p>The default is zero.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get pan():Number
		{
			return _pan;
		}
		
		public final function set pan(value:Number):void
		{
			// Coerce the value into our range:
			if (isNaN(value))
			{
				value = 0;
			}
			else if (value > 1)
			{
				value = 1;
			}
			else if (value < -1)
			{
				value = -1;
			}
			
			if (value != _pan)
			{
				panChangeStart(value);
				
				_pan = value;
				
				panChangeEnd();
			}
		}
	
		// Internals
		//
		
		/**
		 * Called immediately before the <code>volume</code> value is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
		 * @param newVolume New <code>volume</code> value.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function volumeChangeStart(newVolume:Number):void
		{
		} 
		
		/**
		 * Called just after the <code>volume</code> value has changed.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the volumeChange event.</p> 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function volumeChangeEnd():void
		{
			dispatchEvent(new AudioEvent(AudioEvent.VOLUME_CHANGE, false, false, false, _volume));
		}
		
		/**
		 * Called immediately before the <code>muted</code> value is toggled. 
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
		 * @param newMuted New <code>muted</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function mutedChangeStart(newMuted:Boolean):void
		{
		}
		
		/**
		 * Called just after the <code>muted</code> property has been toggled.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the mutedChange event.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function mutedChangeEnd():void
		{
			dispatchEvent(new AudioEvent(AudioEvent.MUTED_CHANGE, false, false, _muted));
		}
				
		/**
		 * Called immediately before the <code>pan</code> value is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
		 * @param newPan New <code>pan</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function panChangeStart(newPan:Number):void
		{	
		}
		
		/**
		 * Called just after the <code>pan</code> value has changed.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the panChange event.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function panChangeEnd():void
		{
			dispatchEvent(new AudioEvent(AudioEvent.PAN_CHANGE, false, false, false, NaN, _pan));
		}

		private var _volume:Number = 1;
		private var _muted:Boolean = false;
		private var _pan:Number = 0;
	}
}