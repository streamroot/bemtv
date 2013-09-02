/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.metadata
{
	/**
	 * The CuePoint class represents a cue point in the timeline of a media
	 * element.
	 * 
	 * <p>A cue point is a media time value that has an associated action or
	 * piece of information.  Typically, cue points are associated with video
	 * timelines to represent navigation points or event triggers.</p>
	 * 
	 * <p>The CuePoint class extends TimelineMarker, and as such can be added
	 * to a TimelineMetadata object.</p>
	 * 
	 *  @includeExample CuePointExample.as -noswf
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class CuePoint extends TimelineMarker
	{
		/**
		 * Namespace URL for a TimelineMetadata class that exposes
		 * embedded cue points.
		 **/
		public static const EMBEDDED_CUEPOINTS_NAMESPACE:String	= "http://www.osmf.org/timeline/embeddedCuePoints/1.0";

		/**
		 * Namespace URL for a TimelineMetadata class that exposes
		 * dynamic cue points.
		 **/
		public static const DYNAMIC_CUEPOINTS_NAMESPACE:String	= "http://www.osmf.org/timeline/dynamicCuePoints/1.0";

		/**
		 * Constructor.
		 * 
		 * @param type The type of cue point specified by one of the const values in CuePointType.
		 * @param time The time value of the cue point in seconds.
		 * @param name The name of the cue point.
		 * @param parameters Custom name/value data for the cue point.
		 * @param duration The duration value for the cue point in seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function CuePoint
			( type:String
			, time:Number
			, name:String
			, parameters:Object
			, duration:Number=NaN
			)
		{
			super(time, duration);
			
			_type = type;
			_name = name;
			_parameters = parameters;
		}
				
		/**
		 * The type of cue point. Returns one of the constant
		 * values defined in CuePointType.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get type():String
		{
			return _type;
		}
				
		/**
		 * The name of the cue point.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get name():String
		{
			return _name;
		}
			
		/**
		 * The parameters of the cue point.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get parameters():Object
		{
			return _parameters;
		}
		
		private var _name:String;
		private var _type:String;
		private var _parameters:Object;	// Custom name/value data for the cue point
	}
}
