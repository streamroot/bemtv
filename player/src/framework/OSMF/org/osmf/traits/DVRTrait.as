/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.traits
{
	import flash.errors.IllegalOperationError;
	
	import org.osmf.events.DVREvent;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * Dispatched when the object's isRecording property changes. 
	 */	
	[Event(name="isRecordingChange", type="org.osmf.events.DVREvent")]
	
	/**
	 * DVRTrait defines the trait interface for media that can be played
	 * while in the process of being recorded, as if with a digital video
	 * recorder (DVR). It can also be used as the base class foor a specific
	 * DVRTrait class.
	 * 
	 * <p>Use the <code>MediaElement.hasTrait(MediaTraitType.DVR)</code> method to query
	 * whether a media element has this trait. 
	 * If <code>hasTrait(MediaTraitType.DVR)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.DVR)</code> method
	 * to get an object of this type.</p>
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */				
	public class DVRTrait extends MediaTraitBase
	{
		/**
		 * Constructor.
		 * 
		 * @param isRecording Defines whether the recording is ongoing.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */				
		public function DVRTrait(isRecording:Boolean = false, windowDuration:Number = -1)
		{
			_isRecording = isRecording;
			_windowDuration = windowDuration;
			
			super(MediaTraitType.DVR);
		}
		
		/**
		 * Defines the window length on the server.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public final function get windowDuration():Number
		{
			return _windowDuration;
		}
		
		/**
		 * Defines if the recording is ongoing.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public final function get isRecording():Boolean
		{
			return _isRecording;
		}
		
		/**
		 * @private
		 * 
		 * Method that allows subclasses to set the isRecording property.
		 * 
		 * @param value The new value for the isRecording property.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setIsRecording(value:Boolean):void
		{
			if (value != _isRecording)
			{
				isRecordingChangeStart(value);
				
				_isRecording = value;
				
				isRecordingChangeEnd();
			}
		}
		
		// Subclass stubs
		//
		
		/**
		 * @private
		 * 
		 * Subclasses may override this method to do processing when the
		 * isRecording property is about to change.
		 * 
		 * @param value The value that isRecording is about to be set to.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function isRecordingChangeStart(value:Boolean):void
		{	
		}
		
		/**
		 * @private
		 * 
		 * Subclasses may override this method to do processing when the
		 * isRecording property has just been changed.
		 * 
		 * <p>Subclasses that override should call this method 
		 * to dispatch the isRecordingChange event.</p> 
		 * 
		 * @param value The value that isRecording has been set to.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function isRecordingChangeEnd():void
		{
			dispatchEvent(new DVREvent(DVREvent.IS_RECORDING_CHANGE));
		}
		
		// Internals
		//
		
		private var _isRecording:Boolean;
		private var _windowDuration:Number;
	}
}