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
package org.osmf.net
{
	import flash.events.EventDispatcher;
	
	/**
	 * NetStreamSwitchManagerBase is a base class for classes that need to
	 * manage transitions between multi-bitrate (MBR) streams.
	 * 
	 * <p>A NetStreamSwitchManagerBase can work in manual or auto mode.  For
	 * the former, it will execute upon request the NetStream call that
	 * performs the switch.  For the latter, it will execute the switch based
	 * on its own internal logic.</p>
	 * 
	 * <p>A NetStreamSwitchManagerBase doesn't dispatch any events indicating
	 * state changes.  The assumption is that a client will already be listening
	 * to events on the NetStream, so there's no need for duplicative events
	 * here.</p>
	 * 
	 * <p>This is an abstract base class, clients must subclass it to implement
	 * their own switching logic.</p>
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */				
	public class NetStreamSwitchManagerBase extends EventDispatcher
	{
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */				
		public function NetStreamSwitchManagerBase()
		{
			super();
			
			_autoSwitch = true;
			_maxAllowedIndex = int.MAX_VALUE;
		}

		/**
		 * Indicates whether the switching manager should automatically
		 * switch between streams.  The default is true.
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
		
		public function set autoSwitch(value:Boolean):void
		{
			_autoSwitch = value;
		}
		
		/**
		 * Returns the current stream index that is rendering on the client.
		 * Note this may differ from the last index requested if this property
		 * is queried after a switch has begun but before it has completed.
		 *
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */				
		public function get currentIndex():uint
		{
			// Subclasses must override.
			return 0;
		}

		/**
		 * The highest stream index that the switching manager is
		 * allowed to switch to.
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
		
		/**
		 * The highest stream index that the switching manager is
		 * allowed to switch to.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */				
		public function set maxAllowedIndex(value:int):void
		{
			_maxAllowedIndex = value;
		}

		/**
		 * Initiate a switch to the stream with the given index.
    	 * Note:  If the media is paused, switching will not take place until after play resumes.	
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */				
		public function switchTo(index:int):void
		{
			// Subclasses must override.
		}
		
		// Internals
		//
		
		protected var _autoSwitch:Boolean;
		protected var _maxAllowedIndex:int;
	}
}