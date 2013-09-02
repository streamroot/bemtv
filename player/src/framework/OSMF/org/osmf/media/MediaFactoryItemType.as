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
package org.osmf.media
{
	/**
	 * MediaFactoryItemType is the enumeration of possible types of MediaFactoryItems.
	 * 
	 * <p>Most MediaFactoryItems encapsulate media that is created and returned
	 * directly, but in some cases a MediaFactoryItem needs to be integrated with
	 * previously-created MediaElements.  This class enables the distinction between
	 * these types.</p> 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaFactoryItemType
	{
		/**
		 * The default type.  Represents MediaFactoryItems for standard, creatable
		 * MediaElements.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const STANDARD:String = "standard";
		
		/**
		 * Represents MediaFactoryItems for ProxyElements that should wrap created
		 * MediaElements.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const PROXY:String = "proxy";
		
		/**
		 * @private
		 * 
		 * All available types should be included in this array.
		 */
		internal static const ALL_TYPES:Array = [STANDARD, PROXY];
	}
}