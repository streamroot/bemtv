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
package org.osmf.layout
{
	import flash.geom.Point;
	
	/**
	 * @private
	 * 
	 * Utility class for working with scale modes.
	 */ 
	internal class ScaleModeUtils
	{				
		/**
		 * Calculates the scaled size based on the scaling algorithm.  
		 * The available width and height are the width and height of the container.
		 * The intrinsic width and height are the width and height of the content.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public static function getScaledSize
			( scaleMode:String
			, availableWidth:Number, availableHeight:Number
			, intrinsicWidth:Number, intrinsicHeight:Number
			):Point
		{
			var result:Point;
			
			switch (scaleMode)
			{
				case ScaleMode.ZOOM:
				case ScaleMode.LETTERBOX:
					
					var availableRatio:Number
						= availableWidth
						/ availableHeight;
						
					var componentRatio:Number 
						= (intrinsicWidth || availableWidth)
						/ (intrinsicHeight || availableHeight);
					
					if 	(	(scaleMode == ScaleMode.ZOOM && componentRatio < availableRatio) 
						||	(scaleMode == ScaleMode.LETTERBOX && componentRatio > availableRatio)
						)
					{
						result 
							= new Point
								( availableWidth
								, availableWidth / componentRatio
								);
					}
					else
					{
						result
							= new Point
								( availableHeight * componentRatio
								, availableHeight
								);
					}

					break;
					
				case ScaleMode.STRETCH:
					
					result 
						= new Point
							( availableWidth
							, availableHeight
							);
					break;
					
				case ScaleMode.NONE:
					
					result
						= new Point
							( intrinsicWidth	|| availableWidth
							, intrinsicHeight	|| availableHeight
							);
					
					break;
			}
			
			return result;
		}
	}
}