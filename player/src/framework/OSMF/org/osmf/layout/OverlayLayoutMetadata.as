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
	 * Defines metadata that holds a number of overlay layout related attributes.
	 * 
	 * The default layout renderer adheres specific semantics to each attribute.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	internal class OverlayLayoutMetadata extends NonSynthesizingMetadata
	{
		/**
		 * @private
		 * 
		 * Identifier for the index property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const INDEX:String = "index";
		
		public function OverlayLayoutMetadata()
		{
			super();
		}
		
		/**
		 * @private
		 */
		override public function getValue(key:String):*
		{
			if (key == INDEX)
			{
				return index;
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
		public function get index():Number
		{
			return _index;
		}
		public function set index(value:Number):void
		{
			if (_index != value)
			{
				var event:MetadataEvent
					= new MetadataEvent(MetadataEvent.VALUE_CHANGE, false, false, INDEX, value, _index);
					
				_index = value;
						
				dispatchEvent(event);
			}
		}
		
		// Internals
		//
		private var _index:Number = NaN;
	}
}