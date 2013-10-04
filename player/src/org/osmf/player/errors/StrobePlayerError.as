/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package org.osmf.player.errors
{
	import org.osmf.events.MediaError;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * Defines the error object as used by the player on throwing
	 * exceptions.
	 */
	public class StrobePlayerError extends Error
	{
		public function StrobePlayerError(errorID:int, detail:String=null)
		{
			super(getMessageForErrorID(errorID), errorID);
			
			_detail = detail;	
		}
		
		/**
		 * An optional string that contains supporting detail for the error.
		 * Typically this string is simply the error detail provided by a
		 * Flash Player API.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get detail():String
		{
			return _detail;
		}
		
		// Protected
		//
		
		/**
		 * Returns the message for the error with the specified ID.  If
		 * the error ID is unknown, returns the empty string.
		 * 
		 * <p>Subclasses should override to provide messages for their
		 * custom errors, as this method returns the value that is exposed in
		 * the <code>message</code> property.</p>
		 * 
		 * @param errorID The ID for the error.
		 * 
		 * @return The message for the error with the specified error ID.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function getMessageForErrorID(errorID:int):String
		{
			return StrobePlayerErrorCodes.getMessageForErrorID(errorID);
		}
		
		// Internals
		//
		
		private var _detail:String;
	}
}