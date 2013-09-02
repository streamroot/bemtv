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
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;

	[ExcludeClass]
	
	/**
	 * Dispatched when an MediaTraitBase is aggregated by the TraitAggregator.
	 * This event is dispatched even if other aggregated media elements already
	 * have a trait of the same type.
	 *
	 * @eventType org.osmf.composition.TraitAggregatorEvent.TRAIT_AGGREGATED
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="traitAggregated",type="org.osmf.composition.TraitAggregatorEvent")]	

	/**
	 * Dispatched when an MediaTraitBase is unaggregated by the TraitAggregator.
	 * This event is dispatched even if other aggregated media elements still
	 * have a trait of the same type.
	 *
	 * @eventType org.osmf.composition.TraitAggregatorEvent.TRAIT_UNAGGREGATED
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="traitUnaggregated",type="org.osmf.composition.TraitAggregatorEvent")]	

	/**
	 * Dispatched when the listened child changes.
	 *
	 * @eventType org.osmf.composition.TraitAggregatorEvent.LISTENED_CHILD_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="listenedChildChange",type="org.osmf.composition.TraitAggregatorEvent")]	

	/**
	 * @private
	 * 
	 * The TraitAggregator provides a view into the traits for a collection
	 * of MediaElements.  A client of this class will add MediaElements to it,
	 * and can then perform operations (and receive events) related to all
	 * instances of the same trait across all MediaElements.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */		 
	public class TraitAggregator extends EventDispatcher
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function TraitAggregator()
		{
			childrenTraits = new Dictionary();		
		}
				
		/**
		 * The Listened child element will be the only element dispatching
		 * trait added / trait removed events.  forEachChildTrait and
		 * invokeOnEachChildTrait will operate on all children, regardless of
		 * the mode.  If this variable is set to null, no children will be
		 * listened to.
		 * 
		 * Dispatches trait removed / trait added events for the previous and
		 * new listenedChild's traits, respectively.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set listenedChild(value:MediaElement):void
		{
			if (value != _listenedChild)
			{
				var traitIndex:int = 0;
				var oldListenedChild:MediaElement = _listenedChild;
				
				if (_listenedChild)
				{
					_listenedChild.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdded);
					_listenedChild.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemoved);
					
					// Dispatch traitUnaggregated events for all traits.
					for (traitIndex = 0; traitIndex < _listenedChild.traitTypes.length; traitIndex++)
					{				
						var removingTraitType:String = _listenedChild.traitTypes[traitIndex];
						dispatchEvent
							( new TraitAggregatorEvent
								( TraitAggregatorEvent.TRAIT_UNAGGREGATED
								, removingTraitType
								, listenedChild.getTrait(removingTraitType)
								, listenedChild
								)
							);			
					}
				}
				
				_listenedChild = value;
				
				if (_listenedChild)
				{
					// Dispatch traitAggregated events for all traits.
					for (traitIndex = 0; traitIndex < _listenedChild.traitTypes.length; traitIndex++)
					{				
						var addingTraitType:String = _listenedChild.traitTypes[traitIndex];
						dispatchEvent
							( new TraitAggregatorEvent
								( TraitAggregatorEvent.TRAIT_AGGREGATED
								, addingTraitType
								, listenedChild.getTrait(addingTraitType)
								, listenedChild
								)
							);			
					}
	
					_listenedChild.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdded);
					_listenedChild.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemoved);
				}
				
				dispatchEvent
					( new TraitAggregatorEvent
						( TraitAggregatorEvent.LISTENED_CHILD_CHANGE
						, null
						, null
						, null
						, oldListenedChild
						, _listenedChild
						)
					);
			}
		}
		
		public function get listenedChild():MediaElement
		{
			return _listenedChild;
		}
		
		/**
		 * Returns the next child after child which has the given trait.  If child is null,
		 * returns the first child with the given trait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function getNextChildWithTrait(child:MediaElement, traitType:String):MediaElement
		{
			var nextChild:MediaElement = null;
			
			var nextIsNextChild:Boolean = (child == null);
			for each (var mediaElement:MediaElement in childMediaElements)
			{
				if (mediaElement.hasTrait(traitType))
				{
					if (nextIsNextChild)
					{
						nextChild = mediaElement;
						break;
					}
					if (mediaElement == child)
					{
						nextIsNextChild = true;
					}
				}
			}
			
			return nextChild;
		}
		
		 /**
         *  Calls the method passed, and passes the trait as an argument.
         *  the signature of method should take one parameter, of type MediaTraitBase.  Here is an example
         *  	function myMethod(trait:MediaTraitBase):void
		 *  Invokes on all traits of type traitType on all children.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function forEachChildTrait(method:Function, traitType:String):void
		{
			for each (var mediaElement:MediaElement in childMediaElements)
			{
				var trait:MediaTraitBase = mediaElement.getTrait(traitType);
				if (trait != null)
				{
					if (method.length == 1)
					{
						method(trait);
					}
					else
					{
						method(trait, mediaElement);
					}
				}
			}
		}
		
	    /**
         *  Calls the method named by method, and applies the arguments in args to each trait of children.
		 *  Invokes on all traits of type traitType on all children.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function invokeOnEachChildTrait(method:String, args:Array, traitType:String):void	
		{			
			for each (var mediaElement:MediaElement in childMediaElements)
			{
				var trait:MediaTraitBase = mediaElement.getTrait(traitType);
				if (trait != null)
				{
					var f:Function = trait[method];
					f.apply(trait, args);
				}
			}
		}
			
		/**
		 *	Returns true any children within this collection have the specified trait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function hasTrait(traitType:String):Boolean
		{
			return getNumTraits(traitType) > 0;
		}
		
		/**
		 * Returns the number of children within this collection that have the specified trait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getNumTraits(traitType:String):int
		{
			var numTraits:int = 0;
			
			var mediaElements:Array = childrenTraits[traitType];
			for each (var mediaElement:MediaElement in mediaElements)
			{
				if (mediaElement.hasTrait(traitType))
				{
					numTraits++;
				}
			}
			
			return numTraits;			
		}
		
		/**
		 * Returns the number of MediaElements aggregated by the aggregator.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get numChildren():int
		{
			return childMediaElements.length;
		}
		
		/**
		 * Returns the child at the given index, null if no child exists at
		 * that index.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getChildAt(index:int):MediaElement
		{
			return childMediaElements[index];
		}
		
		/**
		 * Returns the index of the given child, -1 if the child is not known
		 * by the aggregator.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getChildIndex(child:MediaElement):int
		{
			return childMediaElements.indexOf(child);
		}
		
		/**
		 * Add a child, with traits to be aggregated.  Will cause trait added
		 * events to be dispatched.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function addChild(child:MediaElement):void
		{
			addChildAt(child, childMediaElements.length);
		}
					
		/**
		 * Add a child, with traits to be aggregated, at the given index.  Will
		 * cause trait added events to be dispatched.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
		public function addChildAt(child:MediaElement, index:int):void
		{
			child.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdded);
			child.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemoved);
			
			childMediaElements.splice(index, 0, child);
			
			for each (var traitType:String in child.traitTypes)
			{				
				if (!childrenTraits[traitType])
				{					
					childrenTraits[traitType] = new Array();
				}
				childrenTraits[traitType].push(child);
				
				dispatchEvent
					( new TraitAggregatorEvent
						( TraitAggregatorEvent.TRAIT_AGGREGATED
						, traitType
						, child.getTrait(traitType)
						, child
						)
					);
			}
		}
		
		/**
		 * Remove a child, with traits to be aggregated.  Will cause trait removed events to be dispatched.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function removeChild(child:MediaElement):void
		{	
			child.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdded);
			child.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemoved);

			childMediaElements.splice(childMediaElements.indexOf(child), 1)
			
			for (var traitIndex:Number = 0; traitIndex < child.traitTypes.length; ++traitIndex)
			{
				var removingTraitType:String = child.traitTypes[traitIndex];
				
				var children:Array = childrenTraits[removingTraitType]; 
				children.splice(children.indexOf(child),1);
				
				dispatchEvent
					( new TraitAggregatorEvent
						( TraitAggregatorEvent.TRAIT_UNAGGREGATED
						, removingTraitType
						, child.getTrait(removingTraitType)
						, child
						)
					);		
			}						
		}
		
		/**
		 * Remove a child, with traits to be aggregated, from the given index.
		 * Will cause traits removed events to be dispatched.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function removeChildAt(index:int):void
		{
			if (index < 0 || index >= childMediaElements.length)
			{
				throw new RangeError();
			}
			
			removeChild(childMediaElements[index]);
		}
		
		// Internal Implementation
		//
		
		private function onTraitRemoved(event:MediaElementEvent):void
		{
			var child:MediaElement = event.target as MediaElement;
			
			var children:Array = childrenTraits[event.traitType]; 
			
			if (children != null)
			{
				children.splice(children.indexOf(child),1);
				
				dispatchEvent
					( new TraitAggregatorEvent
						( TraitAggregatorEvent.TRAIT_UNAGGREGATED
						, event.traitType
						, child.getTrait(event.traitType)
						, child
						)
					);
			}
		}
		
		private function onTraitAdded(event:MediaElementEvent):void
		{
			var child:MediaElement = event.target as MediaElement;
			
			var trait:MediaTraitBase = child.getTrait(event.traitType);
			if (!childrenTraits[event.traitType])
			{
				childrenTraits[event.traitType] = new Array();
			}
			childrenTraits[event.traitType].push(child);
			
			dispatchEvent
				( new TraitAggregatorEvent
					( TraitAggregatorEvent.TRAIT_AGGREGATED
					, event.traitType
					, trait
					, child
					)
				);
		}
		
		/**
		 * Dictionary of Arrays of type MediaElement, indexed by traitType.
		 * To access, do something like this:  
		 * 		var mediaElements:Array = childrenTraits[traitType];
		 * 		var trait:MediaTraitBase = mediaElements[0].getTrait(traitType);
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private var childrenTraits:Dictionary;
		
		private var childMediaElements:Array = new Array();
		
		private var _listenedChild:MediaElement;
	}
}
