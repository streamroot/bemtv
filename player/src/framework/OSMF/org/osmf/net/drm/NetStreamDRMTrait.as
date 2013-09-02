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
package org.osmf.net.drm
{
	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaError;
	import org.osmf.traits.DRMTrait;

	CONFIG::FLASH_10_1
	{
	import flash.events.DRMStatusEvent;
	import flash.net.drm.DRMContentData;
	import flash.system.SystemUpdater;
	}

    [ExcludeClass]
    
    /**
	 * @private
	 * 
     * NetStream-specific DRM trait.
     */
	public class NetStreamDRMTrait extends DRMTrait
	{
	CONFIG::FLASH_10_1
	{
		/**
   		 * Constructor.
   		 *  
   		 *  @langversion 3.0
   		 *  @playerversion Flash 10
   		 *  @playerversion AIR 1.5
   		 *  @productversion OSMF 1.0
   		 */ 
		public function NetStreamDRMTrait()
		{
			super();			
			drmServices.addEventListener(DRMEvent.DRM_STATE_CHANGE, onStateChange);		
		}
		
		/**
		 * Data used by the flash player to implement DRM specific content protection.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set drmMetadata(value:Object):void
		{
			if (value != drmServices.drmMetadata)
			{
				drmServices.drmMetadata = value;
			}
		}
	
		public function get drmMetadata():Object
		{
			return drmServices.drmMetadata;
		}
		
		/**
		 * Calls the System Updater's update function
		 * @private
		 */				
		public function update(type:String):SystemUpdater
		{
			return drmServices.update(type);
		}		

		/**
		 * @private
		 */				
		override public function authenticate(username:String = null, password:String = null):void
		{							
			drmServices.authenticate(username, password);
		}

		/**
		 * @private
		 */		
		override public function authenticateWithToken(token:Object):void
		{							
			drmServices.authenticateWithToken(token);
		}
		
		/**
		 * @private
		 * Signals failures from the DRMsubsystem not captured though the 
		 * DRMServices class.
	
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function inlineDRMFailed(error:MediaError):void
		{
			drmServices.inlineDRMFailed(error);
		}
		
		/**
		 * @private
		 * Signals DRM is available, taken from the inline netstream APIs.
		 * Assumes the voucher is available.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.1
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function inlineOnVoucher(event:DRMStatusEvent):void
		{
			drmServices.inlineOnVoucher(event);
		}
		
		// Internals
		//
						
		private function onStateChange(event:DRMEvent):void
		{
			setPeriod(event.period);
			setStartDate(event.startDate);
			setEndDate(event.endDate);	
			setDrmState(event.drmState);
			dispatchEvent(new DRMEvent(DRMEvent.DRM_STATE_CHANGE, drmState, false, false, startDate, endDate, period, event.serverURL,  event.token, event.mediaError));
		}
															
		private var drmServices:DRMServices = new DRMServices();
    }
	}
}