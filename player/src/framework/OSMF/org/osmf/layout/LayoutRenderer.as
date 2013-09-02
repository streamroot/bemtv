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
	import __AS3__.vec.Vector;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.metadata.MetadataWatcher;

	CONFIG::LOGGING
	{
	import org.osmf.logging.Logger;
	}

	/**
	 * A layout renderer that sizes and positions its targets using the LayoutMetadata
	 * that it looks for on its targets.
	 * 
	 * @see org.osmf.layout.LayoutMetadata 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class LayoutRenderer extends LayoutRendererBase
	{
		// Overrides
		//
		
		/**
		 * @private
		 */
		override protected function get usedMetadatas():Vector.<String>
		{
			return USED_METADATAS;
		}
		
		/**
		 * @private
		 */
		override protected function processContainerChange(oldContainer:ILayoutTarget, newContainer:ILayoutTarget):void
		{
			if (oldContainer)
			{
				containerAbsoluteWatcher.unwatch();
				containerAttributesWatcher.unwatch();
			}
			
			if (newContainer)
			{
				containerAbsoluteWatcher
					= new MetadataWatcher
						( newContainer.layoutMetadata
						, MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS
						, null
						, function (..._):void
							{
								invalidate();
							}
						);
				containerAbsoluteWatcher.watch();
				
				containerAttributesWatcher
					= new MetadataWatcher
						( newContainer.layoutMetadata
						, MetadataNamespaces.LAYOUT_ATTRIBUTES
						, null
						, function (facet:LayoutAttributesMetadata):void
							{
								layoutMode = facet ? facet.layoutMode : LayoutMode.NONE
								invalidate();
							}
						);
				containerAttributesWatcher.watch();
			}
			
			invalidate();
		}
		
		/**
		 * @private
		 */
		override protected function processUpdateMediaDisplayBegin(targets:Vector.<ILayoutTarget>):void
		{
			lastCalculatedBounds = null;
		}
		
		/**
		 * @private
		 */
		override protected function processUpdateMediaDisplayEnd():void
		{
			lastCalculatedBounds = null;
		}
		
		/**
		 * @private
		 */
		override protected function processTargetAdded(target:ILayoutTarget):void
		{
			var attributes:LayoutAttributesMetadata = target.layoutMetadata.getValue(MetadataNamespaces.LAYOUT_ATTRIBUTES) as LayoutAttributesMetadata;
			
			// If no layout properties are set on the target ...
			var relative:RelativeLayoutMetadata = target.layoutMetadata.getValue(MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS) as RelativeLayoutMetadata;
			if	(	(layoutMode == LayoutMode.NONE || layoutMode == LayoutMode.OVERLAY)
				&&	relative == null
				&&	attributes == null
				&&	target.layoutMetadata.getValue(MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS) == null
				&&	target.layoutMetadata.getValue(MetadataNamespaces.ANCHOR_LAYOUT_PARAMETERS) == null
				)
			{
				// Set target to take 100% of their container's width and height
				relative = new RelativeLayoutMetadata();
				relative.width = 100;
				relative.height = 100;
				target.layoutMetadata.addValue(MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS, relative);
			
				// Set target to scale letter box layoutMode, centered, by default:
				attributes = new LayoutAttributesMetadata();
				attributes.scaleMode ||= ScaleMode.LETTERBOX;
				attributes.verticalAlign ||= VerticalAlign.MIDDLE;
				attributes.horizontalAlign ||= HorizontalAlign.CENTER;
				target.layoutMetadata.addValue(MetadataNamespaces.LAYOUT_ATTRIBUTES, attributes);
			}
			
			// Watch the index metadata attribute for change:
			//
			
			var watcher:MetadataWatcher = new MetadataWatcher
				( target.layoutMetadata
				, MetadataNamespaces.OVERLAY_LAYOUT_PARAMETERS
				, OverlayLayoutMetadata.INDEX
				, function(..._):void 
					{
						updateTargetOrder(target);
					}
				);
			watcher.watch();
			targetMetadataWatchers[target] = watcher;
		}
		
		/**
		 * @private
		 */
		override protected function processTargetRemoved(target:ILayoutTarget):void
		{
			var watcher:MetadataWatcher = targetMetadataWatchers[target];
			delete targetMetadataWatchers[target];
			
			watcher.unwatch();
			watcher = null;
		}
		
		/**
		 * @private
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override protected function compareTargets(x:ILayoutTarget, y:ILayoutTarget):Number
		{
			var overlayX:OverlayLayoutMetadata
				= x.layoutMetadata.getValue(MetadataNamespaces.OVERLAY_LAYOUT_PARAMETERS)
				as OverlayLayoutMetadata;
				
			var overlayY:OverlayLayoutMetadata
				= y.layoutMetadata.getValue(MetadataNamespaces.OVERLAY_LAYOUT_PARAMETERS)
				as OverlayLayoutMetadata;
				
			var indexX:Number = overlayX ? overlayX.index : NaN;
			var indexY:Number = overlayY ? overlayY.index : NaN;
			
			if (isNaN(indexX) && isNaN(indexY))
			{
				return 1;
			}
			else
			{
				indexX ||= 0;
				indexY ||= 0;
				
				return indexX < indexY
							? -1
							: indexX > indexY
								? 1
								: 0;
			}
		}
		
		/**
		 * @private
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override protected function calculateTargetBounds(target:ILayoutTarget, availableWidth:Number, availableHeight:Number):Rectangle
		{
			var attributes:LayoutAttributesMetadata
				= target.layoutMetadata.getValue(MetadataNamespaces.LAYOUT_ATTRIBUTES) as LayoutAttributesMetadata
				|| new LayoutAttributesMetadata();
			
			if (attributes.includeInLayout == false)
			{
				return new Rectangle(); 
			}
				
			var rect:Rectangle = new Rectangle(0, 0, target.measuredWidth, target.measuredHeight);
			
			var absolute:AbsoluteLayoutMetadata
				= target.layoutMetadata.getValue(MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS)
				as AbsoluteLayoutMetadata;
			
			var deltaX:Number;
			var deltaXExclude:Number = 0;
			var deltaY:Number;
			var deltaYExclude:Number = 0;
			
			var toDo:int = ALL;
			
			// Next, get all absolute layout values, if available:
			if (absolute)
			{
				if (!isNaN(absolute.x))
				{
					rect.x = absolute.x;
					toDo ^= X;							
				}
				
				if (!isNaN(absolute.y))
				{
					rect.y = absolute.y;
					toDo ^= Y;
				}
				
				if (!isNaN(absolute.width))
				{
					rect.width = absolute.width;
					toDo ^= WIDTH;
				}
				
				if (!isNaN(absolute.height))
				{
					rect.height = absolute.height;
					toDo ^= HEIGHT;
				}
			}
			
			// If not all position and size fieds have been set yet, then continue
			// processing relative parameters:
			if (toDo != 0)
			{
				var box:BoxAttributesMetadata;
				var relative:RelativeLayoutMetadata
					= target.layoutMetadata.getValue(MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS)
					as RelativeLayoutMetadata;
						
				if (relative)
				{
					if ((toDo & X) && !isNaN(relative.x))
					{
						rect.x = (availableWidth * relative.x) / 100 || 0;
						toDo ^= X; 
					}
					
					if ((toDo & WIDTH) && !isNaN(relative.width))
					{
						if (layoutMode == LayoutMode.HORIZONTAL)
						{
							box	= container.layoutMetadata.getValue(MetadataNamespaces.BOX_LAYOUT_ATTRIBUTES) as BoxAttributesMetadata
								|| new BoxAttributesMetadata();
								
							rect.width 
								=	( Math.max(0, availableWidth - box.absoluteSum)
									* relative.width
									)
									/ box.relativeSum;
						}
						else
						{
							rect.width = (availableWidth * relative.width) / 100;
						}
							
						toDo ^= WIDTH;
					}
					
					if ((toDo & Y) && !isNaN(relative.y))
					{
						rect.y = (availableHeight * relative.y) / 100 || 0;
						toDo ^= Y;
					}
					
					if ((toDo & HEIGHT) && !isNaN(relative.height))
					{
						if (layoutMode == LayoutMode.VERTICAL)
						{
							box	= container.layoutMetadata.getValue(MetadataNamespaces.BOX_LAYOUT_ATTRIBUTES) as BoxAttributesMetadata
								|| new BoxAttributesMetadata();
								
							rect.height
								= 	( Math.max(0, availableHeight - box.absoluteSum)
									* relative.height
									)
									/ box.relativeSum;
						}
						else
						{
							rect.height = (availableHeight * relative.height) / 100;
						}
						
						toDo ^= HEIGHT;
					}
				}
			}
			
			// before we apply anchors parameters, we need to fill out the 
			// remaining dimensions using the measured ones.
			if (attributes.scaleMode)
			{
				if ( (toDo & WIDTH) || (toDo & HEIGHT))
				{
					if ((toDo  & WIDTH) && !isNaN(target.measuredWidth))
					{
						rect.width = target.measuredWidth;
						toDo ^= WIDTH;
					}
					if ((toDo & HEIGHT) && !isNaN(target.measuredHeight))
					{
						rect.height = target.measuredHeight;
						toDo ^= HEIGHT;
					}
				}
			}
			
			// Last, do anchors: (doing them last is a natural order because we require
			// a set width and x to do 'right', as well as a set height and y to do
			// 'bottom')
			if (toDo != 0)
			{
				var anchors:AnchorLayoutMetadata
					= target.layoutMetadata.getValue(MetadataNamespaces.ANCHOR_LAYOUT_PARAMETERS)
					as AnchorLayoutMetadata;
				
				// Process the anchor parameters:
				if (anchors)
				{
					if ((toDo & X) && !isNaN(anchors.left))
					{
						rect.x = anchors.left;
						toDo ^= X;
					}
					
					if ((toDo & Y) && !isNaN(anchors.top))
					{
						rect.y = anchors.top;
						toDo ^= Y;
					}
					
					if (!isNaN(anchors.right) && availableWidth)
					{
						if ((toDo & X) && !(toDo & WIDTH))
						{
							rect.x = Math.max(0, availableWidth - rect.width - anchors.right);
							toDo ^= X;
						}
						else if ((toDo & WIDTH) && !(toDo & X))
						{
							rect.width = Math.max(0, availableWidth - anchors.right - rect.x);
							toDo ^= WIDTH;
						}
						else
						{
							rect.x = Math.max(0, availableWidth - target.measuredWidth - anchors.right);
							toDo ^= X;
						}
						deltaXExclude += anchors.right;
					}
					
					if (!isNaN(anchors.bottom) && availableHeight)
					{
						if ((toDo & Y) && !(toDo & HEIGHT)) 
						{
							rect.y = Math.max(0, availableHeight - rect.height - anchors.bottom);
							toDo ^= Y;
						}
						else if ((toDo & HEIGHT) && !(toDo & Y))
						{
							rect.height = Math.max(0, availableHeight - anchors.bottom - rect.y);
							toDo ^= HEIGHT;
						}
						else
						{
							rect.y = Math.max(0, availableHeight - target.measuredHeight - anchors.bottom);
							toDo ^= Y;
						}
						deltaYExclude += anchors.bottom;
					}
				}
			}
			
			// Apply padding, if set. Note the bottom and right padding can only be
			// applied when a height and width value are available!
			
			var padding:PaddingLayoutMetadata
				= target.layoutMetadata.getValue(MetadataNamespaces.PADDING_LAYOUT_PARAMETERS)
				as PaddingLayoutMetadata;
			
			if (padding)
			{
				if (!isNaN(padding.left))
				{
					rect.x += padding.left;
				}
				if (!isNaN(padding.top))
				{
					rect.y += padding.top;
				}
				if (!isNaN(padding.right) && !(toDo & WIDTH))
				{
					rect.width -= padding.right + (padding.left || 0);
				}
				if (!isNaN(padding.bottom) && !(toDo & HEIGHT))
				{
					rect.height -= padding.bottom + (padding.top || 0);
				}
			}
			
			// Apply scaling layoutMode:
			if (attributes.scaleMode)
			{
				if ( 
					!isNaN(target.measuredWidth) &&
					!(toDo & WIDTH) && 
					!isNaN(target.measuredHeight) &&
					!(toDo & HEIGHT)
				)
				{
					//  (target.displayObject is LayoutTargetSprite ? rect.height : 
					
					var size:Point = ScaleModeUtils.getScaledSize
						( attributes.scaleMode
						, rect.width
						, rect.height
						, target.measuredWidth
						, target.measuredHeight
						);
					
					deltaX = rect.width - size.x;
					deltaY = rect.height - size.y;
					
					rect.width = size.x;
					rect.height = size.y;
				}
			}
			
			// Set deltas:
			if (layoutMode != LayoutMode.HORIZONTAL)
			{
				deltaX ||= availableWidth - (rect.x || 0) - (rect.width || 0) - deltaXExclude;
			}
			
			if (layoutMode != LayoutMode.VERTICAL)
			{
				deltaY ||= availableHeight - (rect.y || 0) - (rect.height || 0) - deltaYExclude;
			}
			
			// Apply alignment (if there's surpluss space reported:)
			if (deltaY)
			{
				switch (attributes.verticalAlign)
				{
					case null:
					case VerticalAlign.TOP:
						// all set.
						break;
					case VerticalAlign.MIDDLE:
						rect.y += deltaY / 2;
						break;
					case VerticalAlign.BOTTOM:
						rect.y += deltaY;
						break;
				}
			}
			
			if (deltaX)
			{	
				switch (attributes.horizontalAlign)
				{
					case null:
					case HorizontalAlign.LEFT:
						// all set.
						break;
					case HorizontalAlign.CENTER:
						rect.x += deltaX / 2;
						break;
					case HorizontalAlign.RIGHT:
						rect.x += deltaX;
						break;
				}
			}						
			
			// Apply pixel snapping:
			if (attributes.snapToPixel)
			{
			 	rect.x = Math.round(rect.x);
			 	rect.y = Math.round(rect.y);
			 	rect.width = Math.round(rect.width);
			 	rect.height = Math.round(rect.height);
			}
			
			if	(layoutMode == LayoutMode.HORIZONTAL || layoutMode == LayoutMode.VERTICAL)
			{ 
				if (lastCalculatedBounds != null)
				{
					// Apply either the x or y coordinate to apply the desired boxing
					// behavior:
					
					if (layoutMode == LayoutMode.HORIZONTAL)
					{
						rect.x = lastCalculatedBounds.x + lastCalculatedBounds.width;
					}
					else // layoutMode == VERTICAL
					{
						rect.y = lastCalculatedBounds.y + lastCalculatedBounds.height;
					}
				}
				
				lastCalculatedBounds = rect;
			}
			
			CONFIG::LOGGING
			{
				logger.debug
					( "dimensions: {0} available: ({1}, {2}), media: ({3},{4}) target ({5})"
					, rect
					, availableWidth, availableHeight
					, target.measuredWidth, target.measuredHeight,
					target.displayObject
					);
			}
			
			return rect;
		}
		
		/**
		 * @private
		 */		
		override protected function calculateContainerSize(targets:Vector.<ILayoutTarget>):Point
		{
			var size:Point = new Point(NaN, NaN);
			
			var absolute:AbsoluteLayoutMetadata
				= container.layoutMetadata.getValue(MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS)
				as AbsoluteLayoutMetadata;
			
			if (absolute)
			{
				size.x = absolute.width;
				size.y = absolute.height;
			}
			
			if (layoutMode != LayoutMode.NONE && layoutMode != LayoutMode.OVERLAY)
			{
				var boxAttributes:BoxAttributesMetadata = new BoxAttributesMetadata();
				container.layoutMetadata.addValue(MetadataNamespaces.BOX_LAYOUT_ATTRIBUTES, boxAttributes);
			}
			
			if (isNaN(size.x) || isNaN(size.y) || ( layoutMode != LayoutMode.NONE && layoutMode != LayoutMode.OVERLAY))
			{
				// Iterrate over all targets, calculating their bounds, combining the results
				// into a bounds rectangle:
				var containerBounds:Rectangle = new Rectangle();
				var targetBounds:Rectangle;
				var lastBounds:Rectangle;
				
				for each (var target:ILayoutTarget in targets)
				{
					if (target.layoutMetadata.includeInLayout)
					{
						targetBounds = calculateTargetBounds(target, size.x, size.y);
						targetBounds.x ||= 0;
						targetBounds.y ||= 0;
						targetBounds.width ||= target.measuredWidth || 0;
						targetBounds.height ||= target.measuredHeight || 0;
						
						if (layoutMode == LayoutMode.HORIZONTAL)
						{
							if (!isNaN(target.layoutMetadata.percentWidth))
							{
								boxAttributes.relativeSum += target.layoutMetadata.percentWidth;
							}
							else
							{
								boxAttributes.absoluteSum += targetBounds.width;	
							}
							
							if (lastBounds)
							{
								targetBounds.x = lastBounds.x + lastBounds.width;		
							}
							
							lastBounds = targetBounds;
						}
						else if (layoutMode == LayoutMode.VERTICAL)
						{
							if (!isNaN(target.layoutMetadata.percentHeight))
							{
								boxAttributes.relativeSum += target.layoutMetadata.percentHeight;
							}
							else
							{
								boxAttributes.absoluteSum += targetBounds.height;	
							}
							
							if (lastBounds)
							{
								targetBounds.y = lastBounds.y + lastBounds.height;
							}
							
							lastBounds = targetBounds;
						}
						
						containerBounds = containerBounds.union(targetBounds);
					}
				}
				
				size.x ||= (absolute == null || isNaN(absolute.width))
							? containerBounds.width
							: absolute.width;
				size.y ||= (absolute == null || isNaN(absolute.height))
							? containerBounds.height
							: absolute.height;
			}
			
//			CONFIG::LOGGING
//			{
//				logger.debug
//					( "calculated container size ({0}, {1}) (bounds: {2})"
//					, size.x, size.y
//					, containerBounds
//					);
//			}
			
			return size;
		}
		
		// Internals
		//
		private static const USED_METADATAS_COUNT:int = 6;
		private static const USED_METADATAS:Vector.<String> = new Vector.<String>(USED_METADATAS_COUNT, true);
		
		/* static */
		{
			USED_METADATAS[0] = MetadataNamespaces.ABSOLUTE_LAYOUT_PARAMETERS;
			USED_METADATAS[1] = MetadataNamespaces.RELATIVE_LAYOUT_PARAMETERS;
			USED_METADATAS[2] = MetadataNamespaces.ANCHOR_LAYOUT_PARAMETERS;
			USED_METADATAS[3] = MetadataNamespaces.PADDING_LAYOUT_PARAMETERS;
			USED_METADATAS[4] = MetadataNamespaces.LAYOUT_ATTRIBUTES;
			USED_METADATAS[5] = MetadataNamespaces.OVERLAY_LAYOUT_PARAMETERS;
		}
		
		private static const X:int = 0x1;
		private static const Y:int = 0x2;
		private static const WIDTH:int = 0x4;
		private static const HEIGHT:int = 0x8;
		
		private static const POSITION:int = X + Y;
		private static const DIMENSIONS:int = WIDTH + HEIGHT;
		private static const ALL:int = POSITION + DIMENSIONS;
		
		private var layoutMode:String = LayoutMode.NONE;
		private var lastCalculatedBounds:Rectangle;
		
		private var targetMetadataWatchers:Dictionary = new Dictionary();
		private var containerAbsoluteWatcher:MetadataWatcher;
		private var containerAttributesWatcher:MetadataWatcher;
		
		CONFIG::LOGGING private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.layout.LayoutRenderer");
	}
}