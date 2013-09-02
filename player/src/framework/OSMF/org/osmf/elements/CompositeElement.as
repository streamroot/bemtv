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
	import __AS3__.vec.Vector;
	
	import flash.errors.IllegalOperationError;
	
	import org.osmf.elements.compositeClasses.CompositeMediaTraitFactory;
	import org.osmf.elements.compositeClasses.CompositeMetadata;
	import org.osmf.elements.compositeClasses.TraitAggregator;
	import org.osmf.elements.compositeClasses.TraitAggregatorEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * CompositeElement is a media element which encapsulates a collection
	 * of other more granular media elements.  It is generally referred to as
	 * a <b>media composition</b>.
	 * 
	 * <p>The media elements that make up a media composition are treated
	 * as a single, unified media element.  For example, if a media composition
	 * encapsulates a sequence of videos, the CompositeElement will behave as
	 * if it's a single VideoElement, but one which plays several videos in
	 * sequence.</p>
	 * 
	 * <p>Because a CompositeElement maintains a list of MediaElement children,
	 * any of which may be CompositeElements themselves, a media composition
	 * can be expressed as a tree structure.</p>
     *
     * <p>Typically a CompositeElement is not instantiated directly but instead is used as 
     * the base class for creating specific types of media compositions.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class CompositeElement extends MediaElement
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function CompositeElement()
		{
			super();
			
			_traitFactory = new CompositeMediaTraitFactory();
			
			setupTraitAggregator();
		}
		
		/**
		 * The number of child MediaElements in this media composition.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get numChildren():int
		{
			return children.length;
		}
		
		/**
		 * Gets the child at the specified index.
		 * 
		 * @param index The index in the list from which to retrieve the child.
		 * 
		 * @return The child at that index or <code>null</code> if there is none.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getChildAt(index:int):MediaElement
		{
			if (index >= 0 && index < children.length)
			{
				return children[index];
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * Returns the index of the child if it is in the list such that
		 * <code>getChildAt(index) == child</code>.
		 * 
		 * @param child The child to find.
		 * 
		 * @return The index of the child or -1 if the child is not in the
		 * list.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getChildIndex(child:MediaElement):int
		{
			return children.indexOf(child);
		}
		
		/**
		 * Adds the specified child to the end of the list.  Equivalent to
		 * <code>addChildAt(child,numChildren)</code>.
		 * 
		 * @param child The child to add.
		 * 
		 * @throws ArgumentError If child is <code>null</code>. 
		 * @throws RangeError If the specified index is less than zero or
		 * greater than the length of the list.
		 * @throws IllegalOperation If the child is already a child.
		 * 
		 * @return The MediaElement that you pass in the child parameter.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addChild(child:MediaElement):MediaElement
		{
			return addChildAt(child, numChildren);
		}
		
		/**
		 * Adds the child to the list at the specified index.  If a child
		 * already exists at this index, it and all subsequent children
		 * will have their index positions increased by one.
		 * 
		 * @param child The child to add.
		 * @param index The index position at which to add the child.
		 *
		 * @throws ArgumentError If child is <code>null</code>. 
		 * @throws RangeError If the specified index is less than zero or
		 * greater than the length of the list.
		 * @throws IllegalOperation If the child is already a child.
		 * 
		 * @return The MediaElement that you pass in the child parameter.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function addChildAt(child:MediaElement,index:Number):MediaElement
		{
			if (child == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			if (index < 0 || index > numChildren)
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			if (children.indexOf(child) != -1)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_ADDED));
			}
			
			children.splice(index, 0, child);
			
			processAddedChild(child, index);
			
			return child;
		}

		/**
		 * Removes the specified child and returns it.  Equivalent to
		 * <code>removeChildAt(child,getChildIndex(child))</code>.
		 * 
		 * @param child The child MediaElement to remove.
		 * 
		 * @return The MediaElement that you pass in the child parameter.
		 * 
		 * @throws ArgumentError If the child is not a child of this composition.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function removeChild(child:MediaElement):MediaElement
		{
			var index:int = children.indexOf(child);
			if (index == -1)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return removeChildAt(index);
		}
				
		/**
		 * Removes the child at the specified index and returns it.  Any
		 * children with index positions greater than this index have their index positions decreased by one.
		 * 
		 * @param index The index from which to remove the child.
		 * 
		 * @return The child at that index.
		 * 
		 * @throws RangeError If the specified index is less than zero or
		 * greater than the length of the list.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function removeChildAt(index:int):MediaElement
		{
			var child:MediaElement = null;
			
			if (index >= 0 && index < children.length)
			{
				child = children.splice(index, 1)[0] as MediaElement;
				
				processRemovedChild(child);
			}
			else
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return child;
		}

		// Overrides
		//
						
		/**
		 * @private
		 */
		override public function set resource(value:MediaResourceBase):void
		{
			// No-op -- a CompositeElement has no notion of a media resource.
		}
				
		// Protected
		//

		
		/**
		 * @private
		 * 
		 * Invoked when a child of the composite element is added.  Subclasses
		 * can override to do custom processing.
		 */
		protected function processAddedChild(child:MediaElement, index:int):void
		{
			child.addEventListener(MediaErrorEvent.MEDIA_ERROR, onChildError);
			
			compositeMetadata.addChild(child.metadata);
			
			if (traitAggregator)
			{
				// The Trait Aggregator needs to keep track of the traits for the
				// new child.
				traitAggregator.addChildAt(child, index);
			}
		}

		/**
		 * @private
		 * 
		 * Invoked when a child of the composite element is removed.  Subclasses
		 * can override to do custom processing.
		 */
		protected function processRemovedChild(child:MediaElement):void
		{
			child.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onChildError);
			
			if (traitAggregator)
			{
				// The Trait Aggregator no longer needs to keep track of the traits
				// for this child, it has been removed.
				traitAggregator.removeChild(child);
			}
			
			compositeMetadata.removeChild(child.metadata);
		}
		
		/**
		 * @private
		 * 
		 * Invoked when the specified trait of the specified MediaTraitType is aggregated
		 * by the TraitAggregator used by this CompositeElement.  Subclasses
		 * can override to do custom processing.
		 */
		protected function processAggregatedTrait(traitType:String, trait:MediaTraitBase):void
		{
		}

		/**
		 * @private
		 * 
		 * Invoked when the specified trait of the specified MediaTraitType is
		 * unaggregated by the TraitAggregator used by this CompositeElement.
		 * Subclasses can override to do custom processing.
		 */
		protected function processUnaggregatedTrait(traitType:String, trait:MediaTraitBase):void
		{
		}
		
		/**
		 * @private
		 */
		override protected function createMetadata():Metadata
		{
			return new CompositeMetadata();
		}
		
		/**
		 * @private
		 */
		protected function get compositeMetadata():CompositeMetadata
		{
			return CompositeMetadata(metadata);
		}

		/**
		 * @private
		 * 
		 * The TraitAggregator for this CompositeElement.   Used to aggregate
		 * traits across the children of the composition.  Subclasses can set
		 * this via <code>createTraitAggregator()</code>.
		 */
		protected final function get traitAggregator():TraitAggregator
		{
			return _traitAggregator;
		}
		
		/**
		 * @private
		 * 
		 * Factory class used to create composite traits.
		 */
		protected final function get traitFactory():CompositeMediaTraitFactory
		{
			return _traitFactory;
		}

		// Internals
		//
		
		private function setupTraitAggregator():void
		{
			_traitAggregator = new TraitAggregator();
			traitAggregator.addEventListener(TraitAggregatorEvent.TRAIT_AGGREGATED,	  onTraitAggregated);
			traitAggregator.addEventListener(TraitAggregatorEvent.TRAIT_UNAGGREGATED, onTraitUnaggregated);
		}
		
		private function onTraitAggregated(event:TraitAggregatorEvent):void
		{
			processAggregatedTrait(event.traitType, event.trait);
		}
		
		private function onTraitUnaggregated(event:TraitAggregatorEvent):void
		{
			processUnaggregatedTrait(event.traitType, event.trait);
		}
		
		private function onChildError(event:MediaErrorEvent):void
		{
			dispatchEvent(event.clone());
		}

		private var _traitFactory:CompositeMediaTraitFactory;
		private var children:Vector.<MediaElement> = new Vector.<MediaElement>();
		private var _traitAggregator:TraitAggregator;		
	}
}