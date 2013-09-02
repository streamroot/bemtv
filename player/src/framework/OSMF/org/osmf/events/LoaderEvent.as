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
	
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.LoadTrait;
	
	/**
	 * A LoaderBase dispatches a LoaderEvent when a LoadTrait that it's loading
	 * or unloading undergoes a notable load-oriented change.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class LoaderEvent extends Event
	{
		/**
		 * The LoaderEvent.LOAD_STATE_CHANGE constant defines the value of the type
		 * property of the event object for a loadStateChange event.
		 * 
		 * @eventType LOAD_STATE_CHANGE
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const LOAD_STATE_CHANGE:String = "loadStateChange";
		
		/**
		 * Constructor.
		 * 
		 * @param type Event type.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
		 * @param loader The LoaderBase for this event.
		 * @param loadTrait The LoadTrait for this event.
		 * @param oldState The previous state of the loadTrait.
		 * @param newState The new state of the loadTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function LoaderEvent
							( type:String
							, bubbles:Boolean=false
							, cancelable:Boolean=false
							, loader:LoaderBase=null
							, loadTrait:LoadTrait=null
							, oldState:String=null
							, newState:String=null
							)
		{			
			super(type, bubbles, cancelable);
			
			_loader = loader;
			_loadTrait = loadTrait;
			_oldState = oldState;
			_newState = newState;
		}
		
		/**
		 * The loader for this event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get loader():LoaderBase
		{
			return _loader;
		}

		/**
		 * The LoadTrait for this event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get loadTrait():LoadTrait
		{
			return _loadTrait;
		}

		/**
		 * The previous state of the LoadTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get oldState():String
		{
			return _oldState;
		}

		/**
		 * The new state of the LoadTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get newState():String
		{
			return _newState;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new LoaderEvent(type, bubbles, cancelable, loader, loadTrait, oldState, newState);
		}
		
		// Internals
		//
		
		private var _loader:LoaderBase;
		private var _loadTrait:LoadTrait;
		private var _oldState:String;
		private var _newState:String;
	}
}