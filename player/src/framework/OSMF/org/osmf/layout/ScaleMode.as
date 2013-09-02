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
	/**
	 * ScaleMode defines the layout of a single piece of content within
	 * a MediaContainer.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	public final class ScaleMode
	{				
		/**
		 * <code>NONE</code> implies that the media size is set to match its intrinsic size.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const NONE:String 		= "none";
		
		/**
		 * <code>STRETCH</code> sets the width and the height of the content to the
		 * container width and height, possibly changing the content aspect ratio.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public static const STRETCH:String		= "stretch";
		
		/**
		 * <code>LETTERBOX</code> sets the width and height of the content as close to the container width and height
		 * as possible while maintaining aspect ratio.  The content is stretched to a maximum of the container bounds, 
		 * with spacing added inside the container to maintain the aspect ratio if necessary.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public static const LETTERBOX:String 	= "letterbox";
		
		/**
		 * <code>ZOOM</code> is similar to <code>LETTERBOX</code>, except that <code>ZOOM</code> stretches the
		 * content past the bounds of the container, to remove the spacing required to maintain aspect ratio.
		 * This has the effect of using the entire bounds of the container, but also possibly cropping some content.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const ZOOM:String			= "zoom";
	}
}