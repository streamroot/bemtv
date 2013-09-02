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
	
	import org.osmf.metadata.TimelineMarker;

	/**
	 * A TimelineMetadataEvent is dispatched when properties of a TimelineMetadata
	 * object change.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class TimelineMetadataEvent extends MetadataEvent
	{
		/**
		 * The TimelineMetadataEvent.MARKER_TIME_REACHED constant defines the value of the
		 * type property of the event object for a markerTimeReached event. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public static const MARKER_TIME_REACHED:String = "markerTimeReached";
		
		/**
		 * The TimelineMetadataEvent.MARKER_DURATION_REACHED constant defines the value
		 * of the type property of the event object for a markerDurationReached
		 * event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const MARKER_DURATION_REACHED:String = "markerDurationReached";

		/**
		 * The TimelineMetadataEvent.MARKER_ADD constant defines the value
		 * of the type property of the event object for a markerAdd
		 * event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const MARKER_ADD:String = "markerAdd";

		/**
		 * The TimelineMetadataEvent.MARKER_REMOVE constant defines the value
		 * of the type property of the event object for a markerRemove
		 * event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static const MARKER_REMOVE:String = "markerRemove";
		
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function TimelineMetadataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, marker:TimelineMarker=null)
		{
			super(type, bubbles, cancelable, "" + marker.time, marker);
			
			_marker = marker;
		}
		
		/**
		 * The TimelineMarker associated with the event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get marker():TimelineMarker
		{
			return _marker;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new TimelineMetadataEvent(type, bubbles, cancelable, _marker);
		}
		
		private var _marker:TimelineMarker;
	}
}