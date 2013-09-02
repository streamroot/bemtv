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
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Factory class for generating composite media traits.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class CompositeMediaTraitFactory
	{
		/**
		 * Instantiates and returns a new MediaTraitBase which acts as a composite
		 * trait for a homogeneous set of child traits.
		 * 
		 * @param traitType The type of the composite trait (and by extension,
		 * the type of all child traits).
		 * @param traitAggregator The aggregator of all traits within the
		 * composite trait.  Note that the composite trait is only considered
		 * to contain those traits which are of type traitType.
		 * @param mode The composition mode to which the composite trait should
		 * adhere.  See CompositionMode for valid values.
		 * 
		 * @return The composite trait of the specified type.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function createTrait
							( traitType:String
							, traitAggregator:TraitAggregator
							, mode:String
							, owner:MediaElement
							):MediaTraitBase
		{
			var compositeTrait:MediaTraitBase = null;
			
			switch (traitType)
			{
				case MediaTraitType.AUDIO:
					// No distinction between modes for AudioTrait. 
					compositeTrait = new CompositeAudioTrait(traitAggregator);
					break;
					
				case MediaTraitType.BUFFER:
					compositeTrait = new CompositeBufferTrait(traitAggregator, mode);
					break;
				
				case MediaTraitType.DYNAMIC_STREAM:
					compositeTrait
						= mode == CompositionMode.PARALLEL
							? new ParallelDynamicStreamTrait(traitAggregator)
							: new SerialDynamicStreamTrait(traitAggregator);		
					break;
				
				case MediaTraitType.LOAD:
					compositeTrait = new CompositeLoadTrait(traitAggregator, mode);
					break;
				
				case MediaTraitType.PLAY:
					compositeTrait = new CompositePlayTrait(traitAggregator, mode);
					break;
					
				case MediaTraitType.SEEK:
					compositeTrait 
						= mode == CompositionMode.PARALLEL
							?	new ParallelSeekTrait(traitAggregator, owner)
							:	new SerialSeekTrait(traitAggregator, owner);
					break;				

				case MediaTraitType.TIME:
					compositeTrait = new CompositeTimeTrait(traitAggregator, mode, owner);
					break;

				case MediaTraitType.DISPLAY_OBJECT:
					compositeTrait
						= mode == CompositionMode.PARALLEL
							? new ParallelDisplayObjectTrait(traitAggregator, owner)
							: new SerialDisplayObjectTrait(traitAggregator, owner);
					break;
					
				case MediaTraitType.DRM:
					compositeTrait = new CompositeDRMTrait(traitAggregator, owner, mode);
					break;
					
				case MediaTraitType.DVR:
					compositeTrait = new CompositeDVRTrait(traitAggregator, owner, mode);
					break;
					
				default:
					throw new Error(OSMFStrings.getString(OSMFStrings.COMPOSITE_TRAIT_NOT_FOUND));
					break;
			}
			
			return compositeTrait;			
		}
	}
}