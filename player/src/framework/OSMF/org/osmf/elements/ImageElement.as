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
package org.osmf.elements
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	
	import org.osmf.elements.loaderClasses.LoaderLoadTrait;
	import org.osmf.elements.loaderClasses.LoaderUtils;
	import org.osmf.media.LoadableElementBase;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * ImageElement is a media element specifically created for
	 * presenting still images.
	 * It can load and present any PNG, GIF, or JPG image.
	 * <p>The basic steps for creating and using an ImageElement are:
	 * <ol>
	 * <li>Create a new URLResource pointing to the URL of image to be loaded.</li>
	 * <li>Create the new ImageElement, passing the URLResource as a parameter.</li>
	 * <li>Create a new MediaPlayer.</li>
	 * <li>Assign the ImageElement to the MediaPlayer's <code>media</code> property.</li>
	 * <li>Get the DisplayObject from the MediaPlayer's <code>displayObject</code> property,
	 * and add it to the display list.  Note that the <code>displayObject</code> property
	 * may not be immediately available, in which case you can listen for the MediaPlayer's
	 * <code>displayObjectChange</code> event.</li>
	 * <li>When done with the ImageElement, set the MediaPlayer's <code>media</code>
	 * property to null, and remove the DisplayObject from the display list.</li>
	 * </ol>
	 * </p>
	 * 
	 * @includeExample ImageElementExample.as -noswf
	 * 
	 * @see org.osmf.elements.ImageLoader
	 * @see org.osmf.media.MediaElement
	 * @see org.osmf.media.MediaPlayer
	 * @see org.osmf.media.URLResource
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class ImageElement extends LoadableElementBase
	{
		/**
		 * Constructor.
		 * 
		 * @param resource URLResource that points to the image source that the ImageElement
		 * will use.
		 * @param loader ImageLoader used to load the image.  If null, the ImageLoader will be created.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function ImageElement(resource:URLResource=null, loader:ImageLoader=null)
		{
			if (loader == null)
			{
				loader = new ImageLoader();
			}
			super(resource, loader);
		}

		/**
		 * Specifies whether the image should be smoothed when it is scaled.  The default value is false.
		 **/
		public function get smoothing():Boolean
		{
			return _smoothing;			
		}
		
		public function set smoothing(value:Boolean):void
		{
			if (_smoothing != value)
			{
				_smoothing = value;
				
				applySmoothingSetting();
			}
		}

		// Overrides
		//
		
		/**
		 * @private 
		 */ 		
		override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase):LoadTrait
		{
			return new LoaderLoadTrait(loader, resource);
		}

		/**
		 * @private 
		 */ 		
		override protected function processReadyState():void
		{
			var loaderLoadTrait:LoaderLoadTrait = getTrait(MediaTraitType.LOAD) as LoaderLoadTrait;
			
			addTrait(MediaTraitType.DISPLAY_OBJECT, LoaderUtils.createDisplayObjectTrait(loaderLoadTrait.loader, this));
			
			applySmoothingSetting();
		}
		
		/**
		 *  @private 
		 */ 
		override protected function processUnloadingState():void
		{
			removeTrait(MediaTraitType.DISPLAY_OBJECT);	
		}
		
		// Internals
		//
		
		private var _smoothing:Boolean;
		
		private function applySmoothingSetting():void
		{
			var displayObjectTrait:DisplayObjectTrait = getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			if (displayObjectTrait)
			{
				var loader:Loader = displayObjectTrait.displayObject as Loader;
				if (loader != null)
				{
					try
					{
						var bitmap:Bitmap = loader.content as Bitmap;
						if (bitmap != null)
						{
							bitmap.smoothing = _smoothing;
						}
					}
					catch (error:SecurityError)
					{
						// Swallow this, it indicates that a policy file was not
						// available (or not retrieved).
					}
				}
			}
		}
	}
}