/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.player.chrome.configuration
{
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	
	public class LayoutAttributesParser
	{
		public static function parse(xml:XML, layoutMetadata:LayoutMetadata):void
		{
			// Absolute:
			//
			
			var x:Number = Number(xml.@x);
			if (!isNaN(x) && xml.@x != undefined)
			{
				layoutMetadata.x = x;
			}
			
			var y:Number = Number(xml.@y);
			if (!isNaN(y) && xml.@y != undefined)
			{
				layoutMetadata.y = y;
			}
			
			var width:Number = Number(xml.@width);
			if (!isNaN(width) && xml.@width != undefined)
			{
				layoutMetadata.width = width;
			}
			
			var height:Number = Number(xml.@height);
			if (!isNaN(height) && xml.@height != undefined)
			{
				layoutMetadata.height = height;
			}
			
			// Relative:
			//
			
			var percentX:Number = Number(xml.@percentX);
			if (!isNaN(percentX) && xml.@percentX != undefined)
			{
				layoutMetadata.percentX = percentX;
			}
			
			var percentY:Number = Number(xml.@percentY);
			if (!isNaN(percentY) && xml.@percentY != undefined)
			{
				layoutMetadata.percentY = percentY;
			}
			
			var percentWidth:Number = Number(xml.@percentWidth);
			if (!isNaN(percentWidth) && xml.@percentWidth != undefined)
			{
				layoutMetadata.percentWidth = percentWidth;
			}
			
			var percentHeight:Number = Number(xml.@percentHeight);
			if (!isNaN(percentHeight) && xml.@percentHeight != undefined)
			{
				layoutMetadata.percentHeight = percentHeight;
			}
			
			// Anchor:
			//
			
			var left:Number = Number(xml.@left);
			if (!isNaN(left) && xml.@left != undefined)
			{
				layoutMetadata.left = left;
			}
			
			var top:Number = Number(xml.@top);
			if (!isNaN(top) && xml.@top != undefined)
			{
				layoutMetadata.top = top;
			}
			
			var right:Number = Number(xml.@right);
			if (!isNaN(right) && xml.@right != undefined)
			{
				layoutMetadata.right = right;
			}
			
			var bottom:Number = Number(xml.@bottom);
			if (!isNaN(bottom) && xml.@bottom != undefined)
			{
				layoutMetadata.bottom = bottom;
			}

			// Padding:
			//
			
			var paddingLeft:Number = Number(xml.@paddingLeft);
			if (!isNaN(paddingLeft) && xml.@paddingLeft != undefined)
			{
				layoutMetadata.paddingLeft = paddingLeft;
			}
			
			var paddingTop:Number = Number(xml.@paddingTop);
			if (!isNaN(paddingTop) && xml.@paddingTop != undefined)
			{
				layoutMetadata.paddingTop = paddingTop;
			}
			
			var paddingRight:Number = Number(xml.@paddingRight);
			if (!isNaN(paddingRight) && xml.@paddingRight != undefined)
			{
				layoutMetadata.paddingRight = paddingRight;
			}
			
			var paddingBottom:Number = Number(xml.@paddingBottom);
			if (!isNaN(paddingBottom) && xml.@paddingBottom != undefined)
			{
				layoutMetadata.paddingBottom = paddingBottom;
			}
			
			// Attributes:
			//
			
			var index:Number = Number(xml.@index);
			if (!isNaN(index) && xml.@index != undefined)
			{
				layoutMetadata.index = index;
			}
			
			var scaleMode:String = String(xml.@scaleMode || "").toLocaleLowerCase();
			switch(scaleMode)
			{
				case "none": layoutMetadata.scaleMode = ScaleMode.NONE; break;
				case "stretch": layoutMetadata.scaleMode = ScaleMode.STRETCH; break;
				case "letterbox": layoutMetadata.scaleMode = ScaleMode.LETTERBOX; break;
				case "zoom": layoutMetadata.scaleMode = ScaleMode.ZOOM; break;
			}
			
			var verticalAlign:String = String(xml.@verticalAlign || "").toLocaleLowerCase();
			switch(verticalAlign)
			{
				case "top": layoutMetadata.verticalAlign = VerticalAlign.TOP; break;
				case "middle": layoutMetadata.verticalAlign = VerticalAlign.MIDDLE; break;
				case "bottom": layoutMetadata.verticalAlign = VerticalAlign.BOTTOM; break;
			}
			
			var horizontalAlign:String = String(xml.@horizontalAlign || "").toLocaleLowerCase();
			switch(horizontalAlign)
			{
				case "left": layoutMetadata.horizontalAlign = HorizontalAlign.LEFT; break;
				case "center": layoutMetadata.horizontalAlign = HorizontalAlign.CENTER; break;
				case "right": layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT; break;
			}
			
			layoutMetadata.snapToPixel = !(String(xml.@snapToPixel || "").toLocaleLowerCase() == "false");
			
			var layoutMode:String = String(xml.@layoutMode || "").toLocaleLowerCase();
			switch(layoutMode)
			{
				case "none": layoutMetadata.layoutMode = LayoutMode.NONE; break;
				case "horizontal": layoutMetadata.layoutMode = LayoutMode.HORIZONTAL; break;
				case "vertical": layoutMetadata.layoutMode = LayoutMode.VERTICAL; break;
			}
			
			layoutMetadata.includeInLayout = !(String(xml.@includeInLayout || "").toLocaleLowerCase() == "false");
		}
	}
}