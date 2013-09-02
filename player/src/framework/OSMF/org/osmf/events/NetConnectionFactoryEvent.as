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
*  Contributor(s): Akamai Technologies
*  
*****************************************************/

package org.osmf.events
{
	import flash.events.Event;
	import flash.net.NetConnection;
	
	import org.osmf.media.URLResource;
	
	/**
	 * A NetConnectionFactory dispatches a NetConnectionFactoryEvent when it has either
	 * succeeded or failed at establishing a NetConnection. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class NetConnectionFactoryEvent extends Event 
	{
		/**
		 * The NetConnectionFactoryEvent.CREATION_COMPLETE constant defines the value of the
		 * type property of the event object for a NetConnectionFactoryEvent when the 
		 * the class has succeeded in establishing a connected NetConnection.
		 * 
		 * @eventType CREATION_COMPLETE 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const CREATION_COMPLETE:String = "creationComplete";
		
		/**
		 * The NetConnectionFactoryEvent.CREATION_ERROR constant defines the value of the
		 * type property of the event object for a NetConnectionFactoryEvent when the 
		 * the class has failed at establishing a connected NetConnection.
		 * 
		 * @eventType CREATION_ERROR
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const CREATION_ERROR:String = "creationError";

		/**
		 * Constructor.
		 * 
		 * @param type Event type.
 		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
 		 * @param netConnection NetConnection to which this event refers.
 		 * @param resource URLResource to which this event refers.
 		 * @param mediaError Error associated with the creation attempt.  Should only be non-null
		 * when type is CREATION_ERROR.
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function NetConnectionFactoryEvent
			( type:String
			, bubbles:Boolean=false
			, cancelable:Boolean=false
			, netConnection:NetConnection=null
			, resource:URLResource=null
			, mediaError:MediaError=null
			)
		{
			super(type, bubbles, cancelable);

			_netConnection = netConnection;
			_resource = resource;
			_mediaError = mediaError;
		}
		
		/**
		 * NetConnection to which this event refers.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get netConnection():NetConnection
		{
			return _netConnection;
		}

		/**
		 * URLResource to which this event refers.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get resource():URLResource
		{
			return _resource;
		}
		
		/**
		 * Error associated with the creation attempt.  Should only be non-null
		 * when type is CREATION_ERROR.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get mediaError():MediaError
		{
			return _mediaError;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new NetConnectionFactoryEvent(type, bubbles, cancelable, _netConnection, _resource, _mediaError);
		}  
		
		private var _netConnection:NetConnection;
		private var _resource:URLResource;
		private var _mediaError:MediaError
	}
}