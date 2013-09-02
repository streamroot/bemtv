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
	import org.osmf.events.LoadEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * Implementation of LoadTrait which can be a composite media trait.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class CompositeLoadTrait extends LoadTrait
	{
		/**
		 * Constructor.
		 * 
		 * @param traitAggregator The object which is aggregating all instances
		 * of the ILoadable trait within this composite trait.
		 * @param mode The composition mode to which this composite trait
		 * should adhere.  See CompositionMode for valid values.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function CompositeLoadTrait(traitAggregator:TraitAggregator, mode:String)
		{
			super(null, null);
			
			this.traitAggregator = traitAggregator;
			this.mode = mode;
			traitAggregationHelper = new TraitAggregationHelper
				( traitType
				, traitAggregator
				, processAggregatedChild
				, processUnaggregatedChild
				);
		}
		
		override public function dispose():void
		{
			traitAggregationHelper.detach();
			traitAggregationHelper = null;
			
			super.dispose();
		}
		
		/**
		 * @private
		 */
		override public function get bytesLoaded():Number
		{
			var compositeBytesLoaded:Number;
			
			if (mode == CompositionMode.SERIAL)
			{
				var emptyUnitSeen:Boolean = false;
				traitAggregator.forEachChildTrait
					(
						function (mediaTrait:MediaTraitBase):void
						{
							if (!emptyUnitSeen)
							{
						  		var loadTrait:LoadTrait = LoadTrait(mediaTrait);
						  
						  		if (!isNaN(loadTrait.bytesLoaded))
						  		{
						  			// The last contributor to bytesLoaded is
						  			// the first non-fully-downloaded child.
						    		emptyUnitSeen = loadTrait.bytesLoaded < loadTrait.bytesTotal;
					  	    		if (isNaN(compositeBytesLoaded))
					  	    		{
					  	  	  			compositeBytesLoaded = 0;
					  	    		}
						    		compositeBytesLoaded += loadTrait.bytesLoaded;
						  		}
							}
					  	},
					  	MediaTraitType.LOAD
					);
			}
			else // PARALLEL
			{						
				traitAggregator.forEachChildTrait
					(
						function (mediaTrait:MediaTraitBase):void
					  	{
					  		var loadTrait:LoadTrait = LoadTrait(mediaTrait);
					  		if (!isNaN(loadTrait.bytesLoaded))
					  		{
					  	  		if (isNaN(compositeBytesLoaded))
					  	  		{
					  	  			compositeBytesLoaded = 0;
					  	  		}
						  		compositeBytesLoaded += loadTrait.bytesLoaded;
							}						
					  	},
					  	MediaTraitType.LOAD
					);
			}
			return compositeBytesLoaded;
		}
		
		/**
		 * @private
		 */
		override public function get resource():MediaResourceBase
		{
			var value:MediaResourceBase = null;
			
			// For serial compositions, expose the resource of the current
			// child.  For parallel compositions, no return value makes
			// sense.
			if (mode == CompositionMode.SERIAL)
			{
				if (traitAggregator.listenedChild != null)
				{
					value = traitAggregator.listenedChild.resource;
				}
			}
			
			return value;
		}

		/**
		 * @private
		 */
		override public function load():void
		{
			if (mode == CompositionMode.PARALLEL)
			{
				// Call load() on all not-yet-loaded children.
				traitAggregator.forEachChildTrait
					(
					  function(mediaTrait:MediaTraitBase):void
					  {
					     var loadTrait:LoadTrait = LoadTrait(mediaTrait);
					     if (loadTrait.loadState != LoadState.LOADING &&
					     	 loadTrait.loadState != LoadState.READY)
					     {
					     	loadTrait.load();
					     }
					  }
					, MediaTraitType.LOAD
					);
			}
			else // SERIAL
			{
				// Call load() on the current child only.
				var currentLoadTrait:LoadTrait = traitOfCurrentChild;
				if (currentLoadTrait != null &&
					currentLoadTrait.loadState != LoadState.LOADING &&
				    currentLoadTrait.loadState != LoadState.READY)
				{
					currentLoadTrait.load();
				}
			}
		}

		/**
         * @private
		 */
		override public function unload():void
		{
			if (mode == CompositionMode.PARALLEL)
			{
				// Call unload() on all not-yet-unloaded children.
				traitAggregator.forEachChildTrait
					(
					  function(mediaTrait:MediaTraitBase):void
					  {
					     var loadTrait:LoadTrait = LoadTrait(mediaTrait);
					     if (loadTrait.loadState == LoadState.LOADING ||
					     	 loadTrait.loadState == LoadState.READY)
					     {
					     	loadTrait.unload();
					     }
					  }
					, MediaTraitType.LOAD
					);
			}
			else // SERIAL
			{
				// Call unload() on the current child only.
				var currentLoadTrait:LoadTrait = traitOfCurrentChild;
				if (currentLoadTrait != null &&
					currentLoadTrait.loadState == LoadState.LOADING ||
					currentLoadTrait.loadState == LoadState.READY)
				{
					currentLoadTrait.unload();
				}
			}
		}
		
		// Internals
		//
		
		private function processAggregatedChild(child:MediaTraitBase):void
		{
			child.addEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange, false, 0, true);
			child.addEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange, false, 0, true);
			
			if (mode == CompositionMode.PARALLEL)
			{
				if (traitAggregator.getNumTraits(MediaTraitType.LOAD) == 1)
				{
					// The first added child's properties are applied to the
					// composite trait.
					syncToLoadState((child as LoadTrait).loadState);
				}
				else
				{
					// All subsequently added children inherit their properties
					// from the composite trait.
					syncToLoadState(loadState);
				}
			}
			else if (child == traitOfCurrentChild)
			{
				// The first added child's properties are applied to the
				// composite trait.
				syncToLoadState((child as LoadTrait).loadState);
			}
			
			updateBytesTotal();
		}

		private function processUnaggregatedChild(child:MediaTraitBase):void
		{
			child.removeEventListener(LoadEvent.LOAD_STATE_CHANGE, onLoadStateChange);
			child.removeEventListener(LoadEvent.BYTES_TOTAL_CHANGE, onBytesTotalChange);
			
			updateBytesTotal();
		}
		
		private function onLoadStateChange(event:LoadEvent):void
		{
			// For parallel compositions and for the current child in a serial
			// composition, changes from the child propagate to the composite
			// trait.
			if (mode == CompositionMode.PARALLEL ||
				event.target == traitOfCurrentChild)
			{
				syncToLoadState(event.loadState);
			}
		}
		
		private function syncToLoadState(newLoadState:String):void
		{
			// If the state to apply is READY or LOADING, then we load the
			// composition as a whole.  The already-loaded parts will be
			// ignored.
			if (newLoadState == LoadState.LOADING ||
				newLoadState == LoadState.READY)
			{
				load();
			}
			// If the state to apply is UNINITIALIZED or UNLOADING, then we
			// unload the composition as a whole.  The already-unloaded parts
			// will be ignored.
			else if (newLoadState == LoadState.UNINITIALIZED ||
					 newLoadState == LoadState.UNLOADING)
			{
				unload();
			}
			
			updateLoadState();
		}
		
		private function onBytesTotalChange(event:LoadEvent):void
		{
			updateBytesTotal();
		}

		private function updateLoadState():void
		{
			var newLoadState:String;
			
			if (mode == CompositionMode.PARALLEL)
			{
				// Examine all child traits to find out the state that best
				// represents the composite trait.  This state is based on some
				// simple rules about the precedence of states in relation to each
				// other.
				var loadStateInt:int = int.MAX_VALUE;
				traitAggregator.forEachChildTrait
					(
					  function(mediaTrait:MediaTraitBase):void
					  {
					  	 // Find the state with the lowest value.
					     loadStateInt
					     	= Math.min
					     		( loadStateInt
					     		, getIntegerForLoadState(LoadTrait(mediaTrait).loadState)
					     		);
					  }
					, MediaTraitType.LOAD
					);
				
				// Convert the integer back to the composite state.
				newLoadState = 
					   getLoadStateForInteger(loadStateInt)
					|| LoadState.UNINITIALIZED;
			}
			else // SERIAL
			{
				var currentLoadTrait:LoadTrait = traitOfCurrentChild;
				newLoadState = currentLoadTrait
						 	 ? currentLoadTrait.loadState
						 	 : LoadState.UNINITIALIZED;
			}
			
			setLoadState(newLoadState);
		}
		
		private function updateBytesTotal():void
		{
			var compositeBytesTotal:Number;
								
			traitAggregator.forEachChildTrait
				(
					function (mediaTrait:MediaTraitBase):void
				  	{
				  		var loadTrait:LoadTrait = LoadTrait(mediaTrait);
				  		if (!isNaN(loadTrait.bytesTotal))
				  		{
				  	  		if (isNaN(compositeBytesTotal))
				  	  		{
				  	  			compositeBytesTotal = 0;
				  	  		}

					  		compositeBytesTotal += loadTrait.bytesTotal;
						}	
				  	},
				  	MediaTraitType.LOAD
				);
		
			setBytesTotal(compositeBytesTotal);
		}
		
		private function getIntegerForLoadState(loadState:String):int
		{
			if (loadState == LoadState.UNINITIALIZED) 	return UNINITIALIZED_INT;
			if (loadState == LoadState.LOADING)  		return LOADING_INT;
			if (loadState == LoadState.UNLOADING)   	return UNLOADING_INT;
			if (loadState == LoadState.READY)		 	return READY_INT;
			/*  loadState == LoadState.LOAD_ERROR*/ 	return LOAD_ERROR_INT;
		}
		
		private function getLoadStateForInteger(i:int):String
		{
			if (i == UNINITIALIZED_INT) return LoadState.UNINITIALIZED;
			if (i == LOADING_INT)	  return LoadState.LOADING;
			if (i == UNLOADING_INT)	  return LoadState.UNLOADING;
			if (i == READY_INT)	  return LoadState.READY;
			if (i == LOAD_ERROR_INT) return LoadState.LOAD_ERROR;
			/* i out of range */	  return null;
		}
		
		private function get traitOfCurrentChild():LoadTrait
		{
			return   traitAggregator.listenedChild
				   ? traitAggregator.listenedChild.getTrait(MediaTraitType.LOAD) as LoadTrait
				   : null;
		}
		
		// Ordered such that the lowest one takes precedence.  For example,
		// if we have two child traits with states LOAD_ERROR and UNINITIALIZED,
		// then the composite trait has state LOAD_ERROR.
		private static const LOAD_ERROR_INT:int 	= 0;
		private static const UNLOADING_INT:int 		= 1;
		private static const LOADING_INT:int 		= 2;
		private static const UNINITIALIZED_INT:int 	= 3;
		private static const READY_INT:int 			= 4;

		private var traitAggregator:TraitAggregator;
		private var traitAggregationHelper:TraitAggregationHelper;
		private var mode:String;
	}
}