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
package org.osmf.net.httpstreaming.flv
{
	import flash.net.ObjectEncoding;
		
	[ExcludeClass]
	
	/**
	 * @private
	 */ 
	public class FLVTagScriptDataObject extends FLVTag
	{
		public function FLVTagScriptDataObject(type:int = FLVTag.TAG_TYPE_SCRIPTDATAOBJECT)
		{
			super(type);
		}
		
		public function get objects():Array
		{
			var array:Array = new Array();
			bytes.position = TAG_HEADER_BYTE_COUNT;
			while (bytes.bytesAvailable)
			{
				array.push(bytes.readObject());
			}
			return array;
		}
		
		public function set objects(array:Array):void
		{
			bytes.objectEncoding = ObjectEncoding.AMF0;
			bytes.length = TAG_HEADER_BYTE_COUNT;	// truncate
			bytes.position = TAG_HEADER_BYTE_COUNT;
			
			for each (var object:Object in array)
			{
				bytes.writeObject(object);
			}
			
			dataSize = bytes.length - TAG_HEADER_BYTE_COUNT;
		}
	}
}
