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
	[ExcludeClass]

	/**
	 * @private
	 */	
	public class DVRUtils
	{
		public static function calculateOffset(beginOffset:Number, endOffset:Number, currentDuration:Number):Number
		{
			var offset:Number = 0;
			if (endOffset != 0)
			{
				// If an end-offset is set ...
				if (currentDuration > endOffset)
				{
					// ... and more is recorded that the end offset allows
					// to be exposed, than start playing as far back as
					// is allowed:
					offset = currentDuration - endOffset;
				}
				else
				{
					// ... but no the recording is shorter than the 
					// amount of time that is allowed to be viewed, then
					// use the begin offset:
					offset = Math.min(beginOffset, currentDuration);
				}
			}
			else if (beginOffset != 0)
			{
				// The starting point is whatever is lowest: the point from
				// where the viewer is allowed to view the stream, or the
				// available recorded time, so far:
				offset = Math.min(beginOffset, currentDuration);
			}
			
			return offset;			
		}
	}
}