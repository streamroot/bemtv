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
	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaError;
	
	/**
	 * Dispatched when either anonymous or credential-based authentication is needed in order
	 * to playback the media.
	 *
	 * @eventType org.osmf.events.DRMEvent.DRM_STATE_CHANGE
 	 *  
 	 *  @langversion 3.0
 	 *  @playerversion Flash 10.1
 	 *  @playerversion AIR 1.5
 	 *  @productversion OSMF 1.0
 	 */ 
	[Event(name='drmStateChange', type='org.osmf.events.DRMEvent')]
				
	/**
	 * DRMTrait defines the trait interface for media which can be
	 * protected by digital rights management (DRM) technology.  It can also be
	 * used as the base class for a more specific DRMTrait subclass.
	 * 
	 * <p>Both anonymous and credential-based authentication are supported.</p>
	 * 
	 * <p>The workflow for media which has a DRMTrait is that the media undergoes
	 * some type of authentication, after which it is valid (i.e. able to be played)
	 * for a specific time window.</p>
	 * 
	 * <p>Use the <code>MediaElement.hasTrait(MediaTraitType.DRM)</code> method to query
	 * whether a media element has this trait. 
	 * If <code>hasTrait(MediaTraitType.DRM)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.DRM)</code> method
	 * to get an object of this type.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10.1
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 	
	public class DRMTrait extends MediaTraitBase
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function DRMTrait()
		{
			super(MediaTraitType.DRM);
		}
				
		/**
		 * Authenticates the media.  Can be used for both anonymous and credential-based
		 * authentication.  If the media has already been authenticated, this is a no-op.
		 * 
		 * @param username The username.  Should be null for anonymous authentication.
		 * @param password The password.  Should be null for anonymous authentication.
		 * 
		 * @throws IllegalOperationError If the media is not initialized yet.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function authenticate(username:String = null, password:String = null):void
		{
		}
		
		/**
		 * Authenticates the media using an object which serves as a token.  Can be used
		 * for both anonymous and credential-based authentication.  If the media has
		 * already been authenticated, this is a no-op.
		 * 
		 * @param token The token to use for authentication.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function authenticateWithToken(token:Object):void
		{							
		}
		
		/**
		 * The current state of the DRM for this media.  The states are described
		 * in the DRMState enumeration.
		 * 
		 * @see DRMState
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
		 * The start date for the playback window.  Returns null if authentication 
		 * has not yet occurred.
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
		 * The end date for the playback window.  Returns null if authentication 
		 * has not yet occurred.
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
		 * The length of the playback window, in seconds.  Returns NaN if
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
			
		// Internals
		//
		
		/**
		 * Updates the period.
		 * 
		 * @param value The new value for period.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		protected final function setPeriod(value:Number):void
		{
			_period = value;
		}
		
		/**
		 * Updates the start date.
		 * 
		 * @param period The new value for startDate.
		 *   
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected final function setStartDate(value:Date):void
		{
			_startDate = value;
		}
		
		/**
		 * Updates the end date.
		 * 
		 * @param value The new value for endDate.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected final function setEndDate(value:Date):void
		{
			_endDate = value;
		}
		
		
		/**
		 * Updates the drm state.
		 * 
		 * <p>Note that this method doesn't dispatch the drmStateChange event.</p>
		 * 
		 * @param value The new value for drmState.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setDrmState(value:String):void
		{
			_drmState = value;
		}

		private var _drmState:String = DRMState.UNINITIALIZED;	
		private var _period:Number = 0;	
		private var _endDate:Date;	
		private var _startDate:Date;	
	}
}