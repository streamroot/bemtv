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
	/**
	 * A MediaError encapsulates an error related to a MediaElement.  Errors are
	 * represented as error IDs with corresponding messages.  Error IDs zero
	 * through 999 are reserved for use by the framework.
	 * 
	 * <p>A list of all possible framework-level errors can be found in the
	 * MediaErrorCodes class.</p>
	 * 
	 * <p>For custom errors, clients should subclass MediaError and override
	 * <code>getMessageForErrorID</code> to return messages for the custom
	 * errors.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaError extends Error
	{
		/**
		 * Constructor.
		 * 
		 * @param errorID The ID for the error.  Used to look up a corresponding
		 * message.  Error IDs 0-999 are reserved for use by the framework,
		 * and are defined in <code>MediaErrorCodes</code>.
		 * 
		 * @param detail An optional string that contains supporting detail
		 * for the error.  Typically this string is simply the error detail
		 * provided by a Flash Player API.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MediaError(errorID:int, detail:String=null)
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
			return MediaErrorCodes.getMessageForErrorID(errorID);
		}
		
		// Internals
		//
		
		private var _detail:String;
	}
}