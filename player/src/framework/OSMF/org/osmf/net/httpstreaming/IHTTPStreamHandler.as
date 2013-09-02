/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.net.httpstreaming
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * IHTTPStreamHandler interface defines the method and properties for
	 * any class which can be used as a handler for HDS objects.
	 * 
	 * @langversion 3.0
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @productversion OSMF 1.6
	 */ 
	public interface IHTTPStreamHandler
	{
		function get source():IHTTPStreamSource;
		
		function get isOpen():Boolean;
		
		function get streamName():String;
		function get qosInfo():HTTPStreamQoSInfo;
		
		function open(streamName:String):void
		function close():void;
		
		function getDVRInfo(streamName:Object):void;
		function changeQualityLevel(streamName:String):void;
	}
}