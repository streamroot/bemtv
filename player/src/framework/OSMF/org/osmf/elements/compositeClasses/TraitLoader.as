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
package org.osmf.elements.compositeClasses
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * Dispatched when the requested MediaElement has been found, or when it
	 * has been determined that no such MediaElement exists.
	 * 
	 * @eventType org.osmf.composition.events.TraitLoaderEvent.TRAIT_FOUND
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="traitFound",type="org.osmf.composition.events.TraitLoaderEvent")]

	/**
	 * Utility class for doing conditional loads of MediaElements.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class TraitLoader extends EventDispatcher
	{
		/**
		 * Iterates over a list of MediaElements looking for a given trait, and
		 * returns the first MediaElement in the list which either has the trait,
		 * or which acquires the trait as a result of being loaded.  (As such,
		 * has the side effect of loading all MediaElements in the list up until
		 * it finds one with the requested trait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function findOrLoadMediaElementWithTrait(mediaElements:Array, traitType:String):void
		{
			var noSuchTrait:Boolean = true;
			
			for each (var mediaElement:MediaElement in mediaElements)
			{
				var loadTrait:LoadTrait = mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
				
				if (	mediaElement.hasTrait(traitType)
					&&	(	loadTrait == null
						 || loadTrait.loadState == LoadState.READY
						)
				   )
				{
					// If the next MediaElement has the requested trait (and is loaded),
					// then we're done.
					//
					
					noSuchTrait = false;
					
					dispatchFindOrLoadEvent(mediaElement);
					break;
				}
				else if (loadTrait != null &&
						 loadTrait.loadState != LoadState.READY)
				{
					// If the next MediaElement doesn't have the trait, but has
					// the LoadTrait and is not yet loaded, then we should
					// load it in case the trait gets added as a result of the
					// load operation.
					//
					
					// We're not sure yet if there's a trait.
					noSuchTrait = false;

					// We wait for the load to complete.
					loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
					
					// It's possible the trait will be removed prior to the completion
					// of the load.  In that case, we'll need to wait until a new
					// trait gets added and listen to that.
					mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
					
					// Execute the load operation.
					executeLoad(loadTrait, mediaElement);
					
					// Stop iterating, we need to wait until the load completes.
					break;
					
					function onLoadStateChange(event:LoadEvent):void
					{
						var loadTrait:LoadTrait = event.target as LoadTrait;
						if (loadTrait.loadState == LoadState.READY)
						{
							mediaElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
							loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
							
							if (mediaElement.hasTrait(traitType))
							{
								dispatchFindOrLoadEvent(mediaElement);
							}
							else
							{
								// Recursively call this method, after stripping
								// off all MediaElements up to and including
								// the one we're iterating over (i.e. the one
								// we just loaded).
								findOrLoadMediaElementWithTrait
									( mediaElements.slice(mediaElements.indexOf(mediaElement)+1)
									, traitType
									);
							}
						}
					}
					
					function onTraitRemove(event:MediaElementEvent):void
					{
						if (event.traitType == MediaTraitType.LOAD)
						{
							// Our trait got removed mid-stream, we need to wait
							// until we get the new LoadTrait.
							loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
						
							mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
						}
					}
					
					function onTraitAdd(event:MediaElementEvent):void
					{
						if (event.traitType == MediaTraitType.LOAD)
						{
							// Our trait was re-added, now we should load it and
							// wait for completion.
							mediaElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
							
							loadTrait = mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
							loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
							executeLoad(loadTrait, mediaElement);
						}
					}
				}
			}
			
			if (noSuchTrait)
			{
				dispatchFindOrLoadEvent(null);
			}
		}
		
		private function executeLoad(loadTrait:LoadTrait, mediaElement:MediaElement):void
		{
			// If it's already loading, then we only need to wait for
			// the event.
			if (loadTrait.loadState != LoadState.LOADING)
			{
				try
				{
					loadTrait.load();
				}
				catch (error:IllegalOperationError)
				{
					// Translate this to a MediaError.
					mediaElement.dispatchEvent
						( new MediaErrorEvent
							( MediaErrorEvent.MEDIA_ERROR
							, false
							, false
							, new MediaError(MediaErrorCodes.MEDIA_LOAD_FAILED, error.message)
							)
						);
						
					dispatchFindOrLoadEvent(null);
				}
			}
		}
		
		private function dispatchFindOrLoadEvent(mediaElement:MediaElement):void
		{
			dispatchEvent(new TraitLoaderEvent(mediaElement));
		}
	}
}