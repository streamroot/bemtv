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
package org.osmf.elements.audioClasses
{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class SoundLoadTrait extends LoadTrait
	{
		public function SoundLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(loader, resource);
		}
		
		public function get sound():Sound
		{
			return _sound;
		}
		
		public function set sound(value:Sound):void
		{
			_sound = value;
		}
		
		override protected function loadStateChangeStart(newState:String):void
		{
			if (newState == LoadState.READY)
			{
				if (_sound != null)
				{
					_sound.addEventListener(Event.OPEN, bytesTotalCheckingHandler, false, 0, true);
					_sound.addEventListener(ProgressEvent.PROGRESS, bytesTotalCheckingHandler, false, 0, true);
				}
			}
			else if (newState == LoadState.UNINITIALIZED)
			{
				_sound = null;
			}
		}
		
		/**
		 * @private
		 */
		override public function get bytesLoaded():Number
		{
			return _sound ? _sound.bytesLoaded : NaN;
		}
		
		/**
		 * @private
		 */
		override public function get bytesTotal():Number
		{
			return _sound ? _sound.bytesTotal : NaN;
		}
		
		// Internals
		//

		private function bytesTotalCheckingHandler(_:Event):void
		{
			if (lastBytesTotal != _sound.bytesTotal)
			{
				var event:LoadEvent
					= new LoadEvent
						( LoadEvent.BYTES_TOTAL_CHANGE
						, false
						, false
						, null
						, _sound.bytesTotal
						);
						
				lastBytesTotal = _sound.bytesTotal;
				dispatchEvent(event);
			}
		}	
		
		private var lastBytesTotal:Number;
		private var _sound:Sound;
	}
}