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

	internal class SerialElementSegment
	{
		public function SerialElementSegment
			(
			  mediaElement:MediaElement
			, relativeStart:Number
			, relativeEnd:Number
			, unseekable:Boolean = false
			)
		{
			_mediaElement	= mediaElement;
			_relativeStart	= relativeStart;
			_relativeEnd	= relativeEnd;
			_unseekable		= unseekable;
		}
		
		public function get mediaElement():MediaElement
		{
			return _mediaElement;
		}
		
		public function get relativeStart():Number
		{
			return _relativeStart;
		}
		
		public function get relativeEnd():Number
		{
			return _relativeEnd;
		}
		
		public function get unseekable():Boolean
		{
			return _unseekable;
		}
		
		private var _mediaElement:MediaElement;
		private var _relativeStart:Number;
		private var _relativeEnd:Number;
		private var _unseekable:Boolean;
	}
}