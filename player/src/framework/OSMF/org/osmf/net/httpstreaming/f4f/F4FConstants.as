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
package org.osmf.net.httpstreaming.f4f
{
	[ExcludeClass]
	
	/**
	 * @private
	 */ 
	internal class F4FConstants
	{
		internal static const BOX_TYPE_UUID:String = "uuid";
		internal static const BOX_TYPE_ABST:String = "abst";
		internal static const BOX_TYPE_ASRT:String = "asrt";
		internal static const BOX_TYPE_AFRT:String = "afrt";
		internal static const BOX_TYPE_AFRA:String = "afra";
		internal static const BOX_TYPE_MDAT:String = "mdat";
		internal static const BOX_TYPE_MOOF:String = "moof";
		
		internal static const EXTENDED_TYPE:String = "uuid";
				
		internal static const FIELD_SIZE_LENGTH:uint = 4;
		internal static const FIELD_TYPE_LENGTH:uint = 4;
		internal static const FIELD_LARGE_SIZE_LENGTH:uint = 8;
		internal static const FIELD_EXTENDED_TYPE_LENGTH:uint = 16;
		
		internal static const FLAG_USE_LARGE_SIZE:uint = 1;
	}
}