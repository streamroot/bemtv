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
	import org.osmf.elements.compositeClasses.CompositeMetadata;
	import org.osmf.elements.compositeClasses.CompositionMode;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.MediaTraitBase;
	
	/**
	 * ParallelElement is a media composition whose elements are presented
	 * in parallel (concurrently).
	 * 
	 * <p>The media elements that make up a ParallelElement are treated as a
	 * single, unified media element.  For example, if a ParallelElement
	 * encapsulates a image and a piece of audio, the ParallelElement will
	 * behave as if it's a single MediaElement with the audio characteristics
	 * of the audio file and the display characteristics of the image file.</p>
	 * 
	 * <p>Typically, a trait on a ParallelElement is a composite or merged combination
	 * of that trait on all its children.  When a new media element is added as a child
	 * of the media composition,  either its traits or the composite's traits are adjusted
	 * to make the traits of the media composition and its children consistent.</p>
	 * <p> As an example of the first case, consider AudioTrait.
	 * If a client adds a new MediaElement that has its AudioTrait volume at 0.5
	 * to a ParallelElement that has its AudioTrait volume at 0.3,
	 * the AudioTrait volume for the child MediaElement is set to 0.3
	 * to be consistent with ParallelElement's trait.</p>
	 * <p>As an example of the second case, consider BufferTrait.
	 * If the added MediaElement has a BufferTrait, the ParallelElement's
	 * BufferTrait may need to "grow" if the new MediaElement has a
	 * larger buffer than any of its other children. In this case, the buffer of the 
	 * ParallelElement adjusts to the size of its new child.
	 * </p>
	 * 
	 * Here is how each trait is expressed when in parallel:
	 * <ul>
	 * <li>
	 * AudioTrait - The composite trait keeps the audible properties of all
	 * children in sync.  When the volume of a child element (or the composite
	 * element) is changed, the volume is similarly changed for all audible
	 * children (and for the composite trait).
	 * </li>
	 * <li>
	 * BufferTrait - The composite trait is buffering if any child is buffering.
	 * Its length and size are the length and size of the child with the
	 * longest buffer.  Its starting position is the minimum (earliest)
	 * starting position of all of its children.
	 * </li>
	 * <li>
	 * DisplayObjectTrait - If one or more of the composite’s children has the DisplayObjectTrait,
	 * the composite trait’s spatial dimensions are defined by the bounding box
	 * of the DisplayObject referenced by
	 * the <code>displayObject</code> property of the composite's DisplayObjectTrait.
	 * If none of the composite’s children has the DisplayObjectTrait,
	 * the composite trait's <code>mediaWidth</code> is the width of its widest child and its
	 * <code>mediaHeight</code> is the height of its tallest child.
	 * </li>
	 * <li>
	 * DRMTrait - The composite trait attempts to keep the DRM state of all children
	 * in sync.  When a child element is authenticated, all DRM-enabled children are
	 * simultaneously authenticated.
	 * </li>
	 * <li>
	 * DVRTrait - The composite trait attempts to keep the DVR state of all children
	 * in sync.
	 * </li>
	 * <li>
	 * DynamicStreamTrait - The composite trait attempts to keep the dynamic streaming
	 * state of all children in sync.  Specifically, it attempts to keep the
	 * <code>autoSwitch</code> property the same for all elements, and the current
	 * stream items within a similar bitrate range.
	 * </li>
	 * <li>
	 * LoadTrait - The composite trait keeps the load state of all children in
	 * sync.  When a child element (or the composite element) is loaded, all
	 * loadable children (and the composite element) are simultaneously loaded.
	 * </li>
	 * <li>
	 * PlayTrait - The composite trait keeps the pause and play states of all children in
	 * sync.  When a child element (or the composite element) is paused, all
	 * pausable children (and the composite element) are simultaneously paused. 
	 * When a child element (or the composite element) is played, all
	 * playable children (and the composite element) are simultaneously played.
	 * </li>
	 * <li>
	 * SeekTrait - The composite trait keeps the seek state of all children in
	 * sync.  When a child element (or the composite element) performs a seek,
	 * all seekable children (and the composite element) simultaneously perform
	 * that same seek. 
	 * </li>
	 * <li>
	 * TimeTrait - The composite trait represents a timeline that encapsulates
	 * the timelines of all children. Its duration is the maximum of the
	 * durations of all children.  Its position is kept in sync for all
	 * children, with the obvious caveat that a child's position will never be
	 * greater than its duration.
	 * </li>
	 * </ul>
	 * 
	 * 	@includeExample ParallelElementExample.as  -noswf
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class ParallelElement extends CompositeElement
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function ParallelElement()
		{
			super();
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 */
		override protected function createMetadata():Metadata
		{
			var result:Metadata = super.createMetadata();
			CompositeMetadata(result).mode = CompositionMode.PARALLEL;
			
			return result;
		}
		
		/**
		 * @private
		 */			
		override protected function processAggregatedTrait(traitType:String, trait:MediaTraitBase):void
		{
			super.processAggregatedTrait(traitType, trait);
			
			var compositeTrait:MediaTraitBase = getTrait(traitType);

			// Create the composite trait if it doesn't exist yet.
			if (compositeTrait == null)
			{
				compositeTrait = traitFactory.createTrait
						( traitType
						, traitAggregator
						, CompositionMode.PARALLEL
						, this
						);

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
			
			// Remove the composite trait if the unaggregated trait was the
			// last child of the composite trait.
			if (traitAggregator.hasTrait(traitType) == false)
			{
				removeTrait(traitType);
			}
		}
	}
}