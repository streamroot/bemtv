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
package org.osmf.elements.f4mClasses
{
	import flash.utils.ByteArray;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Describes the BootstrapInfo used by media objects.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	public class BootstrapInfo
	{
		/**
		 * The actual bootstrap information in binary format
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var data:ByteArray;
		
		/**
		 * The url that points to a remote location at which the actual binary data of 
		 * the bootstrap information resides
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public var url:String;

 		/**
		 * The profile, or type of bootstrapping represented by this element. 
		 * For the Named Access profile, use "named". For the Range Access Profile, 
		 * use "range". For other bootstrapping profiles, use some other string (i.e. 
		 * the field is extensible). It is required.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public var profile:String;

		/**
		 * The ID of this &lt;bootstrapInfo&gt; element. It is optional. If it is not specified, 
		 * then this bootstrapping block will apply to all &lt;media&gt; elements that don't have a 
		 * bootstrapInfoId property. If it is specified, then this bootstrapping block will apply 
		 * only to those &lt;media&gt; elements that use the same ID in their bootstrapInfoId property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 		
		public var id:String;
	}
}