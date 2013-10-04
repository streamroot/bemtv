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

package org.osmf.player.chrome.assets
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class Scale9Bitmap extends Bitmap
	{
		public function Scale9Bitmap(source:Bitmap, scale9:Rectangle)
		{
			this.scale9 = scale9;
			this.sourceData = source.bitmapData.clone();
			super(source.bitmapData.clone(), source.pixelSnapping, source.smoothing);
		}
		
		// Overrides
		//
		
		override public function set width(value:Number):void
		{
			apply9Scale(value, height);
		}
		
		override public function set height(value:Number):void
		{
			apply9Scale(width, value);
		}
		
		// Internals
		//
		
		private var sourceData:BitmapData;
		private var scale9:Rectangle;
		
		private function apply9Scale(width:Number, height:Number):void
		{
			if (bitmapData)
			{
				bitmapData.dispose();
			}
			
			if	(	width
				&&	height
				&&	(	width != sourceData.width
					||	height != sourceData.height
					)
				)
			{
				bitmapData = new BitmapData(width, height, true, 0);
				
				var sourceWidth:Number = sourceData.width;
				var sourceHeight:Number = sourceData.height;
			
				var rightWidth:Number = sourceHeight - scale9.y - scale9.height;
				var bottomHeight:Number = sourceWidth - scale9.x - scale9.width;
				
				var matrix:Matrix = new Matrix();
				var clipRect:Rectangle = new Rectangle();
				
				
				// [1] | [5] | [2]
				// ---------------
				// [8] | [7] | [9]
				// ---------------
				// [4] | [6] | [3]
				
				// [1]
				clipRect = new Rectangle(0, 0, scale9.x, scale9.y);
				bitmapData.draw(sourceData, matrix, null, null, clipRect, smoothing);
				
				// [2]
				matrix.tx = width - sourceWidth;
				clipRect = new Rectangle(width - bottomHeight, 0, scale9.x, scale9.y);
				bitmapData.draw(sourceData, matrix, null, null, clipRect, smoothing);
				
				// [3]
				matrix.ty = height - sourceHeight;
				clipRect = new Rectangle(width - bottomHeight, height - rightWidth, scale9.x, bottomHeight);
				bitmapData.draw(sourceData, matrix, null, null, clipRect, smoothing);

				// [4]
				matrix.tx = 0;				
				clipRect = new Rectangle(0, height - rightWidth, scale9.x, rightWidth);
				bitmapData.draw(sourceData, matrix, null, null, clipRect, smoothing);
				
				// [5]
				matrix.identity();
				matrix.a = (width - scale9.x - rightWidth) / scale9.width;
				matrix.tx = scale9.x - scale9.x * matrix.a;
				clipRect = new Rectangle(scale9.x, 0, scale9.width * matrix.a, scale9.y); 
				bitmapData.draw(sourceData, matrix, null, null, clipRect, smoothing);
				
				// [6]
				matrix.ty = height - sourceHeight;
				clipRect = new Rectangle(scale9.x, height - rightWidth, scale9.width * matrix.a, bottomHeight); 
				bitmapData.draw(sourceData, matrix, null, null, clipRect, smoothing);
				
				// [7]
				matrix.d = (height - scale9.y - bottomHeight) / scale9.height;
				matrix.ty = scale9.y - scale9.y * matrix.d;
				clipRect = new Rectangle(scale9.x, scale9.y, scale9.width * matrix.a, scale9.height * matrix.d);
				bitmapData.draw(sourceData, matrix, null, null, clipRect, smoothing);
				
				// [8]
				matrix.identity();
				matrix.d = (height - scale9.y - bottomHeight) / scale9.height;
				matrix.ty = scale9.y - scale9.y * matrix.d;
				clipRect = new Rectangle(0, scale9.y, scale9.x, scale9.height * matrix.d); 
				bitmapData.draw(sourceData, matrix, null, null, clipRect, smoothing);
				
				// [9]
				matrix.tx = width - sourceWidth;
				clipRect = new Rectangle(width - rightWidth, scale9.y, rightWidth, scale9.height * matrix.d); 
				bitmapData.draw(sourceData, matrix, null, null, clipRect, smoothing);
			}
			else
			{
				bitmapData = sourceData.clone();
			}
		}
	}
}