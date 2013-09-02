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
	 * A DRMEvent is dispatched when the properties of a DRMTrait change.
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0	 
	 */ 
	public class DRMEvent extends Event
	{		
		/**
		 * The DRMEvent.DRM_STATE_CHANGE constant defines the value
		 * of the type property of the event object for a change to the drmState
		 * of a DRMTrait.
		 * 
		 * @eventType DRM_STATE_CHANGE
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const DRM_STATE_CHANGE:String = "drmStateChange";

		/**
		 * Constructor.
		 * 
		 * @param type The type of the event.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented.
 		 * @param licenseID Specified the unique identifier for this content
 		 * @param prompt The authentication prompt associated with this content.
		 * @param mediaError The error that describes an authentication failure.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function DRMEvent(type:String, state:String, bubbles:Boolean=false, cancelable:Boolean=false, start:Date=null, end:Date=null, period:Number=0, serverURL:String=null, token:Object=null, mediaError:MediaError=null)
		{
			super(type, bubbles, cancelable);
			
			_drmState = state;
			_token = token;
			_mediaError = mediaError;
			_startDate = start;
			_endDate = end;
			_period = period;
			_serverURL = serverURL;
		}
		
		/**
		 * The token returned as a result of a successful authentication.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get token():Object
		{
			return _token;
		}

		/**
		 * The error that describes an authentication failure.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get mediaError():MediaError
		{
			return _mediaError;
		}
		
		/**
		 * The start date for the playback window, null if authentication 
		 * hasn't taken place.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get startDate():Date
		{
			return _startDate;
		}
		
		/**
		 * The end date for the playback window, null if authentication 
		 * hasn't taken place.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get endDate():Date
		{
			return _endDate;
		}
		
		/**
		 * The length of the playback window, in seconds; NaN if
		 * authentication hasn't taken place.
		 * 
		 * <p>Note that this property will generally be the difference between startDate
		 * and endDate, but is included as a property because there may be times where
		 * the duration is known up front, but the start or end dates are not (e.g. a
		 * one week rental).</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get period():Number
		{
			return _period;
		}
		
		/**
		 * The current state of the DRM trait.  Possible values
		 * are listed on the DRMState enumeration.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get drmState():String
		{
			return _drmState;
		}	
						
		/**
		 * The authentication prompt for the DRM content associated with this DRMEvent.  For
		 * localized authentication, this may be an id.
		 */ 
		public function get serverURL():String
		{
			return _serverURL;
		}	
					
				
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new DRMEvent(type, _drmState, bubbles, cancelable, _startDate, _endDate, _period, _serverURL, _token, _mediaError);
		}
		
		private var _drmState:String;
		private var _startDate:Date;
		private var _endDate:Date;
		private var _period:Number;
		private var _serverURL:String;		
		private var _token:Object;
		private var _mediaError:MediaError;
	}
}