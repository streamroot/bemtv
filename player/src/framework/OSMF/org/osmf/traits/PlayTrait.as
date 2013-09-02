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
	import flash.errors.IllegalOperationError;
	
	import org.osmf.events.PlayEvent;
	import org.osmf.utils.OSMFStrings;

	/**
	 * Dispatched when the canPause property has changed.
	 * 
	 * @eventType org.osmf.events.PlayEvent.CAN_PAUSE_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="canPauseChange",type="org.osmf.events.PlayEvent")]

	/**
	 * Dispatched when the playState of the PlayTrait has changed.
	 * 
	 * @eventType org.osmf.events.PlayEvent.PLAY_STATE_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="playStateChange",type="org.osmf.events.PlayEvent")]

	/**
	 * PlayTrait defines the trait interface for media whose playback can be started
	 * and stopped.  It can be used as the base class for a more specific PlayTrait
	 * subclass.
	 * 
	 * <p>Use the <code>MediaElement.hasTrait(MediaTraitType.PLAY)</code> method to query
	 * whether a media element has a trait of this type.
	 * If <code>hasTrait(MediaTraitType.PLAY)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.PLAY)</code> method
	 * to get an object of this type.</p>
	 * 
	 * @see org.osmf.media.MediaElement
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class PlayTrait extends MediaTraitBase
	{
		// Public Interface
		//
		
		/**
		 * Constructor.
		 **/
		public function PlayTrait()
		{
			super(MediaTraitType.PLAY);
			
			_canPause = true;
			_playState = PlayState.STOPPED;
		}
		
		/**
		 * Plays the media if it is not already playing.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public final function play():void
		{
			attemptPlayStateChange(PlayState.PLAYING);
		}
		
		/**
		 * Indicates whether the media can be paused.  If false, then
		 * the pause() method is not supported.
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
		
		/**
		 * Pauses the media if it is not already paused.
		 * 
		 * @throws IllegalOperationError If canPause returns false.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public final function pause():void
		{
			if (canPause)
			{
				attemptPlayStateChange(PlayState.PAUSED);
			}
			else
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.PAUSE_NOT_SUPPORTED));
			}
		}
		
		/**
		 * Stops the media if it is not already stopped.
		 * 
		 * <p>When media is stopped, then any subsequent call to
		 * <code>play</code> should start from the beginning (though
		 * this is up to the actual implementation).</p> 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public final function stop():void
		{
			attemptPlayStateChange(PlayState.STOPPED);
		}
		
		/**
		 * The current playback state, of type PlayState.
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

		// Internals
		//
		
		/**
		 * Sets the canPause property for this PlayTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected final function setCanPause(value:Boolean):void
		{
			if (value != _canPause)
			{
				_canPause = value;
				
				dispatchEvent(new PlayEvent(PlayEvent.CAN_PAUSE_CHANGE, false, false, playState, _canPause));
			}
		}
		
		/**
		 * Called immediately before the <code>playState</code> property value is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p> 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function playStateChangeStart(newPlayState:String):void
		{
		}
		
		/**
		 * Called just after the <code>playState</code> property value
		 * has changed. Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the relevant PlayEvent.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function playStateChangeEnd():void
		{
			dispatchEvent(new PlayEvent(PlayEvent.PLAY_STATE_CHANGE, false, false, playState));
		}
		
		private function attemptPlayStateChange(newPlayState:String):void
		{	
			if (_playState != newPlayState)
			{
				playStateChangeStart(newPlayState);
					
				_playState = newPlayState;
					
				playStateChangeEnd();
			}
		}
				
		private var _playState:String;
		private var _canPause:Boolean;
	}
}