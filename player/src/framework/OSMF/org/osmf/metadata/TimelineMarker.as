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
package org.osmf.metadata
{
	/**
	 * The TimelineMarker class represents an individual marker in the timeline
	 * of a MediaElement.
	 * 
	 * <p>TimelineMarker objects are aggregated by a TimelineMetadata object.</p>
	 * 
	 * @see TimelineMetadata
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 **/
	public class TimelineMarker
	{
		/**
		 * Constructor.
		 * 
		 * @param time Time in seconds.
		 * @param duration The duration in seconds.  Default to NaN, which indicates
		 * that the duration is undefined.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function TimelineMarker(time:Number, duration:Number=NaN)
		{
			super();
			
			_time = time;
			_duration = duration;
		}

		/**
		 * The time in seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get time():Number
		{
			return _time;
		}
		
		/**
		 * The duration in seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get duration():Number
		{
			return _duration;
		}
		
		private var _time:Number;		// The time in seconds
		private var _duration:Number;	// The duration in seconds
	}
}