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
	import flash.utils.Dictionary;
	
	import org.osmf.elements.compositeClasses.CompositeMetadata;
	import org.osmf.elements.compositeClasses.CompositionMode;
	import org.osmf.elements.compositeClasses.IReusable;
	import org.osmf.elements.compositeClasses.TraitAggregatorEvent;
	import org.osmf.events.SerialElementEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.MediaTraitBase;
	
	/**
	 * SerialElement is a media composition whose elements are presented
	 * serially (i.e. in sequence).
	 * 
	 * <p>The media elements that make up a SerialElement are treated as a
	 * single, unified media element.  For example, if a SerialElement
	 * encapsulates a sequence of videos, the SerialElement will behave as
	 * if it's a single VideoElement, but one which plays several videos in
	 * sequence.</p>
	 * 
  	 * <p>Typically, a trait on a SerialElement is a reflection of the "current"
  	 * child of the composition.  A SerialElement plays through its children
  	 * in serial order.  As the current child completes its execution, the next
  	 * child in the sequence becomes the "current" child.  To a client of the
  	 * class, the changes from one current child to the next are hidden. They
  	 * are only noticeable through changes to the traits of this class.</p>
	 * 
	 * <p>A childless SerialElement has no notion of a "current" child, so
	 * it reflects no traits.  The first child that
	 * is added to a SerialElement immediately becomes the current child
	 * of the composition.  If the current child is removed, the next
	 * child in the sequence becomes the new current
	 * child, if there is a next child. If there is no next child,
	 * the first child in the sequence becomes the current child.</p>  
	 * <p>The only way that the "current" status can pass from one
	 * child to another is when the state of one of the current child's 
	 * traits changes in such a way that the
	 * SerialElement knows that it needs to change its current child.  For
	 * example, if each child in the sequence has the PlayTrait,
	 * the "current" status advances from one child to the next when a 
	 * child finishes playing and its PlayTrait's <code>PlayState</code>
	 * property changes from <code>PLAYING</code> to <code>STOPPED</code>.  
	 * Another example:  if the client of a SerialElement with a SeekTrait
	 * seeks from one point to another, the "current"
	 * status is likely to change from one child to another.</p>   
	 * 
	 * <p>Here is how each trait is expressed when in serial:</p>
	 * <ul>
	 * <li>
	 * AudioTrait - The composite trait keeps the audible properties of all
	 * children in sync.  When the volume of a child element (or the composite
	 * element) is changed, the volume is similarly changed for all audible
	 * children (and for the composite trait).
	 * </li>
	 * <li>
	 * BufferTrait - The composite trait represents the bufferable trait of
	 * the current child in the sequence.  Any changes apply only to the
	 * current child.
	 * </li>
	 * <li>
	 * DisplayObjectTrait - The composite trait represents the DisplayObjectTrait of the
	 * current child in the sequence.
	 * </li>
	 * <li>
	 * DRMTrait - The composite trait represents the DRMTrait of the
	 * current child in the sequence.
	 * </li>
	 * <li>
	 * DVRTrait - The composite trait represents the DVRTrait of the
	 * current child in the sequence.
	 * </li>
	 * <li>
	 * DynamicStreamTrait - The composite trait represents the DynamicStreamTrait of the
	 * current child in the sequence.  Any changes apply only to the current
	 * child.
	 * </li>
	 * <li>
	 * LoadTrait - The composite trait represents the LoadTrait of the
	 * current child in the sequence.  Any changes apply only to the current
	 * child.
	 * </li>
	 * <li>
	 * PlayTrait - The composite trait represents the PlayTrait of the
	 * current child in the sequence.  Any changes apply only to the current
	 * child. 
	 * </li>
	 * <li>
	 * SeekTrait - The composite trait represents the SeekTrait of the
	 * current child in the sequence.  A seek operation can change the current
	 * child.
	 * </li>
	 * <li>
	 * TimeTrait - The composite trait represents a timeline that encapsulates
	 * the timeline of all children.  Its duration is the sum of the durations
	 * of all children.  Its position is the sum of the positions of the first
	 * N fully complete children, plus the position of the next child.
	 * </li>
	 * </ul>
	 * 
	 * 	@includeExample SerialElementExample.as -noswf
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class SerialElement extends CompositeElement
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function SerialElement()
		{
			super();
			
			traitAggregator.addEventListener
				( TraitAggregatorEvent.LISTENED_CHILD_CHANGE
				, onListenedChildChanged
				);
				
			reusableTraits = new Dictionary();
		}
		
		/**
		 * The currently active child of this SerialElement.
		 **/
		public function get currentChild():MediaElement
		{
			return traitAggregator.listenedChild;
		}

		/**
		 * @private
		 **/
		override public function get resource():MediaResourceBase
		{
			return 	  traitAggregator.listenedChild != null
					? traitAggregator.listenedChild.resource
					: null;
		}
		
		// Protected
		//
				
		/**
		 * @private
		 * 
		 * Deprecated method.
		 * 
		 * Method invoked after the currentChild property has changed.  The base implementation
		 * does nothing.
		 * 
		 * Clients can override this to do custom processing when the current child changes. 
		 **/
		protected function currentChildChange():void
		{
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 */
		override protected function createMetadata():Metadata
		{
			var result:Metadata = super.createMetadata();
			CompositeMetadata(result).mode = CompositionMode.SERIAL;
			
			return result;
		}
			
		/**
		 * @private
		 */
		override protected function processAddedChild(child:MediaElement, index:int):void
		{
			super.processAddedChild(child, index);
			
			// The first added child of a SerialElement becomes the "current"
			// child (i.e. the child from which all traits of the composite
			// element come).			
			if (traitAggregator.listenedChild == null)
			{
				traitAggregator.listenedChild = child;
			}
			
			updateListenedChildIndex();
		}

		/**
		 * @private
		 */
		override protected function processRemovedChild(child:MediaElement):void
		{
			super.processRemovedChild(child);

			// If we remove the current child, then we should set a new
			// current child (if one is available).
			if (traitAggregator.listenedChild == child)
			{
				// Our first choice for the new current child is the next
				// child.
				var newListenedChild:MediaElement = getChildAt(listenedChildIndex);
				
				// If there is no next child, then we pick the first child.
				if (newListenedChild == null)
				{
					listenedChildIndex = (numChildren > 0) ? 0 : -1;

					newListenedChild = getChildAt(listenedChildIndex);
				}
				
				traitAggregator.listenedChild = newListenedChild;
			}
			
		}
		
		/**
		 * @private
		 */
		override protected function processAggregatedTrait(traitType:String, trait:MediaTraitBase):void
		{
			super.processAggregatedTrait(traitType, trait);
			
			var compositeTrait:MediaTraitBase = getTrait(traitType);
			
			// Create the composite trait if the aggregated trait is for the
			// current child, the reason being that aggregating a new trait on
			// a non-current child shouldn't cause a new trait to be reflected. 
			if	(	compositeTrait == null
				&&	traitAggregator.listenedChild != null
				&&	traitAggregator.listenedChild.getTrait(traitType) == trait
				)
			{
				compositeTrait = reusableTraits[traitType] as MediaTraitBase;
				if (compositeTrait == null)
				{
					compositeTrait = traitFactory.createTrait
							( traitType
							, traitAggregator
							, CompositionMode.SERIAL
							, this
							);
				}
				else
				{
					(compositeTrait as IReusable).attach();
					reusableTraits[traitType] = null;
				}
				
				if (compositeTrait != null)
				{
					addTrait(traitType, compositeTrait);
				}
			}			
		}

		/**
		 * @private
		 */
		override protected function processUnaggregatedTrait(traitType:String, trait:MediaTraitBase):void
		{
			super.processUnaggregatedTrait(traitType, trait);
			
			// Remove the composite trait if the unaggregated trait comes from
			// the current child, the reason being that the composition should
			// not reflect a trait that doesn't exist on the current child.
			if	(	traitAggregator.listenedChild != null
				&&	traitAggregator.listenedChild.getTrait(traitType) == trait
				)
			{
				var trait:MediaTraitBase = removeTrait(traitType);
				if (trait != null && trait is IReusable) 
				{
					(trait as IReusable).detach();
					reusableTraits[traitType] = trait;
				}
			}
		}
	
		// Internals
		//
				
		private function onListenedChildChanged(event:TraitAggregatorEvent):void
		{
			compositeMetadata.activeChild
				= event.newListenedChild 
					? event.newListenedChild.metadata
					: null;
					
			// Update the index of the current child.
			updateListenedChildIndex();
			
			// Inform any interested subclasses of the change.
			currentChildChange();
			
			// Dispatch the change event.
			dispatchEvent(new SerialElementEvent(SerialElementEvent.CURRENT_CHILD_CHANGE, false, false, currentChild));
		}

		private function updateListenedChildIndex():void
		{
			listenedChildIndex = traitAggregator.getChildIndex(traitAggregator.listenedChild);
		}
		
		private var listenedChildIndex:int = -1;
		private var reusableTraits:Dictionary;
	}
}