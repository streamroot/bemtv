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
package org.osmf.media
{
	import org.osmf.events.LoadEvent;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * LoadableElementBase is the base class for media elements that
	 * have a LoadTrait.  It manages the registration of event listeners,
	 * and provides protected hook methods to simplify the load workflow
	 * for subclasses.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class LoadableElementBase extends MediaElement
	{
		/**
		 * Constructor.
		 * 
		 * @param resource The MediaResourceBase that represents the piece of
		 * media to load into this media element.
		 * @param loader Loader used to load the media.  If null, then this class
		 * is responsible for selecting/generating the appropriate loader.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function LoadableElementBase(resource:MediaResourceBase=null, loader:LoaderBase=null)
		{
			super();
			
			_loader = loader;
			this.resource = resource;
		}
		
		/**
		 * @private
		 */
		override public function set resource(value:MediaResourceBase):void
	    {
			super.resource = value;
			
			updateLoadTrait();
		}
		
		// Protected
		//
		
		/**
		 * The LoaderBase used by this element to load resources.
		 **/
		protected final function get loader():LoaderBase
		{
			return _loader;
		}

		protected final function set loader(value:LoaderBase):void
		{
			_loader = value;
		}
		
		/**
		 * Subclasses can override this method to return a custom LoadTrait
		 * subclass.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase):LoadTrait
		{
			return new LoadTrait(_loader, resource);
		}
				
		/**
		 * 
		 * Subclasses can override this method to do processing when the media
		 * element enters the LOADING state.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function processLoadingState():void
		{
			// Subclass stub
		}
		
		/**
		 * Subclasses can override this method to do processing when the media
		 * element enters the READY state.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function processReadyState():void
		{
			// Subclass stub
		}
		
		/**
		 * Subclasses can override this method to do processing when the media
		 * element enters the UNLOADING state.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function processUnloadingState():void
		{
			// Subclass stub
		}
		
		/**
		 * @private
		 * 
		 * Given a resource, this method will locate the first LoaderBase which can handle
		 * the resource and set it as the loader for this class.  Gives precedence to the
		 * current loader first, then the alternateLoaders, in order.
		 **/
		protected function getLoaderForResource(resource:MediaResourceBase, alternateLoaders:Vector.<LoaderBase>):LoaderBase
		{
			// Assume it's the original loader.
			var result:LoaderBase = loader;
			
			if (resource != null && (loader == null || loader.canHandleResource(resource) == false))
			{
				// Don't call canHandleResource twice on the same loader.
				var loaderFound:Boolean = false;
				
				for each (var alternateLoader:LoaderBase in alternateLoaders)
				{
					// Skip this one if it's the same as the current loader.
					if (loader == null || loader != alternateLoader)
					{
						if (alternateLoader.canHandleResource(resource))
						{
							result = alternateLoader;
							break;
						}
					}
				}
				
				// If none was found that can handle the resource, pick the
				// last one, if only so that errors will be dispatched
				// further downstream.
				if (result == null && alternateLoaders != null)
				{
					result = alternateLoaders[alternateLoaders.length - 1];
				}
			}
			
			return result;
		}
		
		// Private
		//
		
		private function onLoadStateChange(event:LoadEvent):void
		{
			// The asymmetry between READY and UNLOADING (versus UNINITIALIZED) is
			// motivated by the fact that once a media is already unloaded, one
			// cannot reference it any longer. Triggering the event upfront the
			// actual unload being effectuated allows listeners to still act on
			// the media that is about to be unloaded.
			
			if (event.loadState == LoadState.LOADING)
			{
				processLoadingState();
			}
			else if (event.loadState == LoadState.READY)
			{
				processReadyState();
			}
			else if (event.loadState == LoadState.UNLOADING)
			{
				processUnloadingState();
			}
		}

		private function updateLoadTrait():void
		{
			var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
			if (loadTrait != null)
			{
				// Remove (and unload) any existing LoadTrait.
				if (loadTrait.loadState == LoadState.READY)
				{	    			   
					loadTrait.unload();	 
				}

				loadTrait.removeEventListener
					( LoadEvent.LOAD_STATE_CHANGE
					, onLoadStateChange
					);
				
				removeTrait(MediaTraitType.LOAD);
			}
			
			if (loader != null)
			{
				// Add a new LoadTrait for the current resource.
				loadTrait = createLoadTrait(resource, loader);
				loadTrait.addEventListener
					( LoadEvent.LOAD_STATE_CHANGE
					, onLoadStateChange, false, 10 // Using a higher priority event listener in order to process load state changes before clients.
					);
				
				addTrait(MediaTraitType.LOAD, loadTrait);
			}
		}

		private var _loader:LoaderBase;
	}
}