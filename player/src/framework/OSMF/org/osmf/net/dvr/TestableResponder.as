/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.net.dvr
{
	import flash.net.Responder;

	[ExcludeClass]

	/**
	 * @private 
	 * 
	 * Subclasses Responder in a way that allows unit testing.
	 */	
	internal class TestableResponder extends Responder
	{
		public function TestableResponder(result:Function, status:Function=null)
		{
			_result = result;
			_status = status;
			
			super(result, status);
		}
	
		internal function get result():Function
		{
			return _result;
		}
		
		internal function get status():Function
		{
			return _status;
		}
		
		private var _result:Function;
		private var _status:Function;	
	}
}