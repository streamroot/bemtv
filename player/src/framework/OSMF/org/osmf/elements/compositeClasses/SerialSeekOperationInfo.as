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
package org.osmf.elements.compositeClasses
{
	import org.osmf.media.MediaElement;
	
	internal class SerialSeekOperationInfo extends CompositeSeekOperationInfo
	{
		public function SerialSeekOperationInfo()
		{
			super();		
		}
		
		public function get seekForward():Boolean
		{
			return _seekForward;
		}
		
		public function set seekForward(value:Boolean):void
		{
			_seekForward = value;
		}
		
		public function get fromChild():MediaElement
		{
			return _fromChild;
		}
		
		public function set fromChild(value:MediaElement):void
		{
			_fromChild = value;
		}
		
		public function get toChild():MediaElement
		{
			return _toChild;
		}
		
		public function set toChild(value:MediaElement):void
		{
			_toChild = value;
		}
		
		public function get toChildTime():Number
		{
			return _toChildTime;
		}
		
		public function set toChildTime(value:Number):void
		{
			_toChildTime = value;
		}
		
		public function set inBetweenChildren(value:Array):void
		{
			_inBetweenChildren = value;
		}

		public function get inBetweenChildren():Array
		{
			if (_inBetweenChildren == null)
			{
				_inBetweenChildren = new Array();
			}
			return _inBetweenChildren;
		}
		
		private var _seekForward:Boolean
		private var _fromChild:MediaElement;
		private var _toChild:MediaElement;
		private var _toChildTime:Number;
		private var _inBetweenChildren:Array;
	}
}