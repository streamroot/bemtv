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
	import org.osmf.events.MetadataEvent;
	import org.osmf.metadata.NonSynthesizingMetadata;

	/**
	 * @private
	 *
	 *  Defines metadata that defines x, y, width and height values.
	 * 
	 * On encountering this on a target, the default layout renderer
	 * will use the set values to position and size the target according to
	 * the absolute values set.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	internal class AbsoluteLayoutMetadata extends NonSynthesizingMetadata
	{
		/**
		 * @private
		 * 
		 * Identifier for the x property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const X:String = "x";
		
		/**
		 * @private
		 * 
		 * Identifier for the y property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const Y:String = "y";
		
		/**
		 * @private
		 * 
		 * Identifier for the width property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const WIDTH:String = "width";
		
		/**
		 * @private
		 * 
		 * Identifier for the height property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const HEIGHT:String = "height";
		
		/**
		 * Constructor.
		 **/
		public function AbsoluteLayoutMetadata()
		{
			super();
		}
		
		/**
		 * @private
		 */
		override public function getValue(key:String):*
		{
			if (key == null)
			{
				return undefined;
			}
			else if (key == X)
			{
				return x;
			}
			else if (key == Y)
			{
				return y;
			}
			else if (key == WIDTH)
			{
				return width;
			}
			else if (key == HEIGHT)
			{
				return height;
			}
			else 
			{
				return undefined;
			}
		}
		
		// Public interface
		//
		
		/**
		 * @private
		 */		
		public function get x():Number
		{
			return _x;
		}
		public function set x(value:Number):void
		{
			if (_x != value)
			{
				var event:MetadataEvent
					= new MetadataEvent(MetadataEvent.VALUE_CHANGE, false, false, X, value, _x);
				
				_x = value;
						
				dispatchEvent(event);
			}
		}
		
		/**
		 * @private
		 */	
		public function get y():Number
		{
			return _y;
		}
		public function set y(value:Number):void
		{
			if (_y != value)
			{
				var event:MetadataEvent
					= new MetadataEvent(MetadataEvent.VALUE_CHANGE, false, false, Y, value, _y);
					
				_y = value;
						
				dispatchEvent(event);
			}
		}
		
		/**
		 * @private
		 */	
		public function get width():Number
		{
			return _width;
		}
		public function set width(value:Number):void
		{
			if (_width != value)
			{
				var event:MetadataEvent
					= new MetadataEvent(MetadataEvent.VALUE_CHANGE, false, false, WIDTH, value, _width);
					
				_width = value;
						
				dispatchEvent(event);
			}
		}
		
		/**
		 * @private
		 */	
		public function get height():Number
		{
			return _height;
		}
		public function set height(value:Number):void
		{
			if (_height != value)
			{
				var event:MetadataEvent
					= new MetadataEvent(MetadataEvent.VALUE_CHANGE, false, false, HEIGHT, value, _height);
					
				 _height = value;
						
				dispatchEvent(event);
			}
		}
		
		// Internals
		//
		
		private var _x:Number;
		private var _y:Number;
		private var _width:Number;
		private var _height:Number;
	}
}