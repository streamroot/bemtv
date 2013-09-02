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
package org.osmf.traits
{
	import flash.display.DisplayObject;
	
	import org.osmf.events.DisplayObjectEvent;

	/**
	 * Dispatched when the trait's <code>displayObject</code> property has changed.
	 * This occurs when a different DisplayObject is assigned to represent the media.
	 * 
	 * @eventType org.osmf.events.DisplayObjectEvent.DISPLAY_OBJECT_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="displayObjectChange",type="org.osmf.events.DisplayObjectEvent")]

	/**
	 * Dispatched when the trait's mediaWidth and/or mediaHeight property has changed.
	 * 
	 * @eventType org.osmf.events.DisplayObjectEvent.MEDIA_SIZE_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="mediaSizeChange",type="org.osmf.events.DisplayObjectEvent")]

	/**
	 * DisplayObjectTrait defines the trait interface for media that expose a DisplayObject,
	 * and which may have intrinsic dimensions. The intrinsic dimensions of a piece of
	 * media refer to its dimensions without regard to those observed when it is projected
	 * onto the stage.
	 * 
	 * <p>For an image, for example, the intrinsic dimensions are the height and 
	 * width of the image as it is stored.</p>
	 * 
	 * <p>Use the <code>MediaElement.hasTrait(MediaTraitType.DISPLAY_OBJECT)</code> method to query
	 * whether a media element has a trait of this type.
	 * If <code>hasTrait(MediaTraitType.DISPLAY_OBJECT)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.DISPLAY_OBJECT)</code> method
	 * to get an object that is of this type.</p>
	 * 
	 * @see org.osmf.media.MediaElement
	 * @see flash.display.DisplayObject
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class DisplayObjectTrait extends MediaTraitBase
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function DisplayObjectTrait(displayObject:DisplayObject, mediaWidth:Number=0, mediaHeight:Number=0)
		{
			super(MediaTraitType.DISPLAY_OBJECT);
			
			_displayObject = displayObject;
			_mediaWidth = mediaWidth;
			_mediaHeight = mediaHeight;
		}
		
		/**
		 * The media's display object.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get displayObject():DisplayObject
		{
			return _displayObject;
		}
		
		/**
		 * The intrinsic width of the media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get mediaWidth():Number
		{
			return _mediaWidth;
		}
		
		/**
		 * The intrinsic height of the media.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get mediaHeight():Number
		{
			return _mediaHeight;
		}
		
		// Internals
		//
		
		/**
		 * Defines the trait's displayObject. If the displayObject is different from the one
		 * that is currently set, a displayObjectChange event will be dispatched.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setDisplayObject(value:DisplayObject):void
		{
			if (_displayObject != value)
			{
				displayObjectChangeStart(value);
				
				var oldDisplayObject:DisplayObject = _displayObject;
				_displayObject = value;
				
				displayObjectChangeEnd(oldDisplayObject);
			}
		}

		/**
		 * Sets the trait's width and height.
		 * 
		 * <p>Forces non numerical and negative values to zero.</p>
		 * 
		 * <p>If the either the width or the height differs from the
		 * previous width or height, dispatches a mediaSizeChange event.</p>
		 * 
		 * @param width The new width.
		 * @param height The new height.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setMediaSize(mediaWidth:Number, mediaHeight:Number):void
		{
			if	(	mediaWidth != _mediaWidth
				||	mediaHeight != _mediaHeight
				)
			{
				mediaSizeChangeStart(mediaWidth, mediaHeight);
				
				var oldMediaWidth:Number = _mediaWidth;
				var oldMediaHeight:Number = _mediaHeight;
				
				_mediaWidth = mediaWidth;
				_mediaHeight = mediaHeight;
				
				mediaSizeChangeEnd(oldMediaWidth, oldMediaHeight);
			}
		}
				
		/**
		 * Called immediately before the <code>displayObject</code> property is changed. 
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
		 * @param newView New <code>displayObject</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function displayObjectChangeStart(newView:DisplayObject):void
		{
		}
		
		/**
		 * Called just after the <code>displayObject</code> property has changed.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method to
		 * dispatch the displayObjectChange event.</p>
		 *  
		 * @param oldDisplayObject Previous <code>displayObject</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function displayObjectChangeEnd(oldDisplayObject:DisplayObject):void
		{
			dispatchEvent(new DisplayObjectEvent(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, false, false, oldDisplayObject, _displayObject));
		}
				
		/**
		 * Called just before a call to <code>setMediaSize()</code>. 
		 * Subclasses can override this method to communicate the change to the media.
		 * @param newMediaWidth New <code>mediaWidth</code> value.
		 * @param newMediaHeight New <code>mediaHeight</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function mediaSizeChangeStart(newMediaWidth:Number, newMediaHeight:Number):void
		{
		}
		
		/**
		 * Called just after <code>setMediaSize()</code> has applied new mediaWidth
		 * and/or mediaHeight values. Dispatches the change event.
		 * 
		 * <p>Subclasses that override should call this method 
		 * to dispatch the mediaSizeChange event.</p>
		 *  
		 * @param oldMediaWidth Previous <code>mediaWidth</code> value.
		 * @param oldMediaHeight Previous <code>mediaHeight</code> value.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function mediaSizeChangeEnd(oldMediaWidth:Number, oldMediaHeight:Number):void
		{
			dispatchEvent(new DisplayObjectEvent(DisplayObjectEvent.MEDIA_SIZE_CHANGE, false, false, null, null, oldMediaWidth, oldMediaHeight, _mediaWidth, _mediaHeight));
		}

		private var _displayObject:DisplayObject;
		private var _mediaWidth:Number = 0;
		private var _mediaHeight:Number = 0;
	}
}