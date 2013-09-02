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
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.layout
{
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.metadata.MetadataSynthesizer;
	import org.osmf.metadata.NullMetadataSynthesizer;
	
	/**
	 * Defines a metadata object that contains the properties upon which a layout
	 * renderer will base its layout.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0	
	 * 
	 *  @includeExample LayoutMetadataExample.as -noswf 
	 */	
	public class LayoutMetadata extends Metadata
	{
		/**
		 * Namespace URL for LayoutMetadata objects when added to a MediaElement or
		 * MediaContainer.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0	 
		 **/
		public static const LAYOUT_NAMESPACE:String	= "http://www.osmf.org/layout/1.0";

		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0	 
		 **/
		public function LayoutMetadata()
		{
			super();
		}
		
		// LayoutAttributes
		//
		
		/**
		 * Defines the desired position of the target in the display list
		 * of its context.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get index():Number
		{
			return lazyOverlay ? lazyOverlay.index : NaN;
		}
		public function set index(value:Number):void
		{
			eagerOverlay.index = value;
		}
		
		/**
		 * Defines the desired scaleMode to be applied to the target.
		 * 
		 * Possible values are on org.osmf.layout.ScaleMode.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get scaleMode():String
		{
			return lazyAttributes ? lazyAttributes.scaleMode : null;
		}
		public function set scaleMode(value:String):void
		{
			eagerAttributes.scaleMode = value;
		}
		
		/**
		 * Defines the desired horizontal alignment to be applied to the
		 * target when layout of the target leaves surplus horizontal blank
		 * space.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get horizontalAlign():String
		{
			return lazyAttributes ? lazyAttributes.horizontalAlign : null;
		}
		public function set horizontalAlign(value:String):void
		{
			eagerAttributes.horizontalAlign = value;
		}
		
		/**
		 * Defines the desired vertical alignment to be applied to the
		 * target when layout of the target leaves surplus vertical blank
		 * space.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get verticalAlign():String
		{
			return lazyAttributes ? lazyAttributes.verticalAlign : null;
		}
		public function set verticalAlign(value:String):void
		{
			eagerAttributes.verticalAlign = value;
		}

		/**
		 * When set to true, the target's calculated position and size will
		 * be rounded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get snapToPixel():Boolean
		{
			return lazyAttributes ? lazyAttributes.snapToPixel : true;
		}
		public function set snapToPixel(value:Boolean):void
		{
			eagerAttributes.snapToPixel = value;
		}
		
		/**
		 * When set to LayoutMode.HORIZONTAL or LayoutMode.VERTICAL,
		 * then the renderer will ignore its target's positioning settings (either
		 * influencing X or Y, depending on the layoutMode chosen), laying out its elements
		 * adjacent in the index specified by the 'index' property.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get layoutMode():String
		{
			return lazyAttributes ? lazyAttributes.layoutMode : LayoutMode.NONE;
		}
		public function set layoutMode(value:String):void
		{
			eagerAttributes.layoutMode = value;
		}

		/**
		 * When set to true (default), the target will participate in the layout
		 * process. When set to false, it will be ignored.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get includeInLayout():Boolean
		{
			return lazyAttributes ? lazyAttributes.includeInLayout : true;
		}
		public function set includeInLayout(value:Boolean):void
		{
			eagerAttributes.includeInLayout = value;
		}

		// AbsoluteLayoutFacet
		//

		/**
		 * Defines the desired horizontal offset of a target expressed in
		 * pixels.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get x():Number
		{
			return lazyAbsolute ? lazyAbsolute.x : NaN;		
		}
		public function set x(value:Number):void
		{
			eagerAbsolute.x = value
		}
		
		/**
		 * Defines the desired vertical offset of a target expressed in
		 * pixels.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get y():Number
		{
			return lazyAbsolute ? lazyAbsolute.y : NaN;		
		}
		public function set y(value:Number):void
		{
			eagerAbsolute.y = value
		}
		
		/**
		 * Defines the desired horizontal size of a target expressed in
		 * pixels.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get width():Number
		{
			return lazyAbsolute ? lazyAbsolute.width : NaN;
		}
		public function set width(value:Number):void
		{
			eagerAbsolute.width = value;
		}
		
		/**
		 * Defines the desired vertical offset of a target expressed in
		 * pixels.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get height():Number
		{
			return lazyAbsolute ? lazyAbsolute.height : NaN;
		}
		public function set height(value:Number):void
		{
			eagerAbsolute.height = value;
		}
		
		// RelativeLayoutFacet
		//
		
		/**
		 * Defines the desired horizontal offset of a target expressed as
		 * a percentage of its container's width.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get percentX():Number
		{
			return lazyRelative ? lazyRelative.x : NaN;		
		}
		public function set percentX(value:Number):void
		{
			eagerRelative.x = value
		}
		
		/**
		 * Defines the desired vertical offset of a target expressed as
		 * a percentage of its container's height.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get percentY():Number
		{
			return lazyRelative ? lazyRelative.y : NaN;		
		}
		public function set percentY(value:Number):void
		{
			eagerRelative.y = value
		}
		
		/**
		 * Defines the desired width of a target expressed as
		 * a percentage of its container's width.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get percentWidth():Number
		{
			return lazyRelative ? lazyRelative.width : NaN;
		}
		public function set percentWidth(value:Number):void
		{
			eagerRelative.width = value;
		}
		
		/**
		 * Defines the desired height of a target expressed as
		 * a percentage of its container's height.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get percentHeight():Number
		{
			return lazyRelative ? lazyRelative.height : NaN;
		}
		public function set percentHeight(value:Number):void
		{
			eagerRelative.height = value;
		}
		
		// AnchorLayoutFacet
		//
		
		/**
		 * Defines the desired horizontal offset of the target in pixels. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get left():Number
		{
			return lazyAnchor ? lazyAnchor.left : NaN;		
		}
		public function set left(value:Number):void
		{
			eagerAnchor.left = value
		}
		
		/**
		 * Defines the desired vertical offset of the target in pixels.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get top():Number
		{
			return lazyAnchor ? lazyAnchor.top : NaN;		
		}
		public function set top(value:Number):void
		{
			eagerAnchor.top = value
		}
		
		/**
		 * Defines how many pixels should be present between the right-hand 
		 * side of the target's bounding box, and the right-hand side
		 * of its container.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get right():Number
		{
			return lazyAnchor ? lazyAnchor.right : NaN;
		}
		public function set right(value:Number):void
		{
			eagerAnchor.right = value;
		}
		
		/**
		 * Defines how many pixels should be present between the bottom
		 * side of the target's bounding box, and the bottom side
		 * of its container.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get bottom():Number
		{
			return lazyAnchor ? lazyAnchor.bottom : NaN;
		}
		public function set bottom(value:Number):void
		{
			eagerAnchor.bottom = value;
		}
		
		// PaddingLayoutFacet
		//
		
		/**
		 * Defines the thickness of the blank space that is to be placed
		 * at the target's left-hand side.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get paddingLeft():Number
		{
			return lazyPadding ? lazyPadding.left : NaN;		
		}
		public function set paddingLeft(value:Number):void
		{
			eagerPadding.left = value
		}
		
		/**
		 * Defines the thickness of the blank space that is to be placed
		 * at the target's top side.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get paddingTop():Number
		{
			return lazyPadding ? lazyPadding.top : NaN;		
		}
		public function set paddingTop(value:Number):void
		{
			eagerPadding.top = value
		}
		
		/**
		 * Defines the thickness of the blank space that is to be placed
		 * at the target's right-hand side.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get paddingRight():Number
		{
			return lazyPadding ? lazyPadding.right : NaN;
		}
		public function set paddingRight(value:Number):void
		{
			eagerPadding.right = value;
		}
		
		/**
		 * Defines the thickness of the blank space that is to be placed
		 * at the target's bottom side.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get paddingBottom():Number
		{
			return lazyPadding ? lazyPadding.bottom : NaN;
		}
		public function set paddingBottom(value:Number):void
		{
			eagerPadding.bottom = value;
		}
		
		/**
		 * @private
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function toString():String
		{
			return "abs ["
				 + x + ", "
				 + y + ", "
				 + width + ", "
				 + height + "] "
				 + "rel ["
				 + percentX + ", "
				 + percentY + ", "
				 + percentWidth + ", "
				 + percentHeight + "] "
				 + "anch ("
				 + left + ", "
				 + top + ")("
				 + right + ", "
				 + bottom + ") "
				 + "pad [" 
				 + paddingLeft + ", "
				 + paddingTop + ", "
				 + paddingRight + ", "
				 + paddingBottom + "] "
				 + "layoutMode: " + layoutMode + " "
				 + "index: " + index + " "
				 + "scale: " + scaleMode + " "
				 + "valign: " + verticalAlign + " "
				 + "halign: " + horizontalAlign + " "
				 + "snap: " + snapToPixel;
		}
		
		/**
		 * @private
		 **/	
		override public function get synthesizer():MetadataSynthesizer
		{
			return SYNTHESIZER;
		}
		
		// Internals
		//
		
		private function get lazyAttributes():LayoutAttributesMetadata
		{
			return getValue(MetadataNamespaces.LAYOUT_ATTRIBUTES) as LayoutAttributesMetadata;
		}
		
		private function get eagerAttributes():LayoutAttributesMetadata
		{
			var result:LayoutAttributesMetadata = lazyAttributes;
			if (result == null)
			{
				result = new LayoutAttributesMetadata();
				addValue(MetadataNamespaces.LAYOUT_ATTRIBUTES, result);
			}
			return result;
		}

		private function get lazyOverlay():OverlayLayoutMetadata
		{
			return getValue(MetadataNamespaces.OVERLAY_LAYOUT_PARAMETERS) as OverlayLayoutMetadata;
		}
		
		private function get eagerOverlay():OverlayLayoutMetadata
		{
			var result:OverlayLayoutMetadata = lazyOverlay;
			if (result == null)
			{
				result = new OverlayLayoutMetadata();
				addValue(MetadataNamespaces.OVERLAY_LAYOUT_PARAMETERS, result);
			}
			return result;
		}

		private function get lazyAbsolute():AbsoluteLayoutMetadata
		{
			return getValue(MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS) as AbsoluteLayoutMetadata;
		}
		
		private function get eagerAbsolute():AbsoluteLayoutMetadata
		{
			var result:AbsoluteLayoutMetadata = lazyAbsolute;
			if (result == null)
			{
				result = new AbsoluteLayoutMetadata();
				addValue(MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS, result);
			}
			return result;
		}
		
		private function get lazyRelative():RelativeLayoutMetadata
		{
			return getValue(MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS) as RelativeLayoutMetadata;
		}
		
		private function get eagerRelative():RelativeLayoutMetadata
		{
			var result:RelativeLayoutMetadata = lazyRelative;
			if (result == null)
			{
				result = new RelativeLayoutMetadata();
				addValue(MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS, result);
			}
			return result;
		}
		
		private function get lazyAnchor():AnchorLayoutMetadata
		{
			return getValue(MetadataNamespaces.ANCHOR_LAYOUT_PARAMETERS) as AnchorLayoutMetadata;
		}
		
		private function get eagerAnchor():AnchorLayoutMetadata
		{
			var result:AnchorLayoutMetadata = lazyAnchor;
			if (result == null)
			{
				result = new AnchorLayoutMetadata();
				addValue(MetadataNamespaces.ANCHOR_LAYOUT_PARAMETERS, result);
			}
			return result;
		}
		
		private function get lazyPadding():PaddingLayoutMetadata
		{
			return getValue(MetadataNamespaces.PADDING_LAYOUT_PARAMETERS) as PaddingLayoutMetadata;
		}
		
		private function get eagerPadding():PaddingLayoutMetadata
		{
			var result:PaddingLayoutMetadata = lazyPadding;
			if (result == null)
			{
				result = new PaddingLayoutMetadata();
				addValue(MetadataNamespaces.PADDING_LAYOUT_PARAMETERS, result);
			}
			return result;
		}
		
		/* static */
		private const SYNTHESIZER:NullMetadataSynthesizer = new NullMetadataSynthesizer();
	}
}