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
	 * An AudioEvent is dispatched when the properties of an AudioTrait change.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class AudioEvent extends Event
	{
		/**
		 * The AudioEvent.VOLUME_CHANGE constant defines the value
		 * of the type property of the event object for a volumeChange
		 * event.
		 * 
		 * @eventType VOLUME_CHANGE 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const VOLUME_CHANGE:String = "volumeChange";
		
		/**
		 * The AudioEvent.MUTED_CHANGE constant defines the value
		 * of the type property of the event object for a mutedChange
		 * event.
		 * 
		 * @eventType MUTED_CHANGE
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const MUTED_CHANGE:String = "mutedChange";

		/**
		 * The AudioEvent.PAN_CHANGE constant defines the value
		 * of the type property of the event object for a panChange
		 * event.
		 * 
		 * @eventType PAN_CHANGE 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const PAN_CHANGE:String = "panChange";

		/**
		 * Constructor.
		 * 
		 * @param type The type of the event.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
 		 * @param buffering Specifies whether or not the trait is currently buffering. 
 		 * @param time The new bufferTime for the trait. 
		 * @param oldVolume Previous volume.
		 * @param newVolume New volume.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function AudioEvent(type:String, bubbles:Boolean, cancelable:Boolean, muted:Boolean=false, volume:Number=NaN, pan:Number=NaN)
		{
			super(type, bubbles, cancelable);
			
			_muted = muted;
			_volume = volume;
			_pan = pan;
		}
		
		/**
		 * New <code>muted</code> value resulting from this change.
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

		/**
		 * New <code>volume</code> value resulting from this change.
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
		
		/**
		 * New <code>pan</code> value resulting from this change.
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
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new AudioEvent(type, bubbles, cancelable, _muted, _volume, _pan);
		}
		
		// Internals
		//
		
		private var _muted:Boolean;
		private var _volume:Number;
		private var _pan:Number;
		
	}
}