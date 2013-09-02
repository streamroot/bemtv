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
	import org.osmf.events.AudioEvent;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * Implementation of AudioTrait which can be a composite media trait.
	 * 
	 * For both parallel and serial media elements, a composite audio trait
	 * keeps all audio properties in sync for the composite element and its
	 * children.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class CompositeAudioTrait extends AudioTrait implements IReusable
	{
		/**
		 * Constructor.
		 * 
		 * @param traitAggregator The object which is aggregating all instances
		 * of the AudioTrait within this composite trait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function CompositeAudioTrait(traitAggregator:TraitAggregator)
		{
			super();
			
			this.traitAggregator = traitAggregator;
			traitAggregationHelper = new TraitAggregationHelper
				( traitType
				, traitAggregator
				, processAggregatedChild
				, processUnaggregatedChild
				);
		}
		
		/**
		 * @private
		 */
		public function attach():void
		{
			traitAggregationHelper.attach();
		}
		
		/**
		 * @private
		 */
		public function detach():void
		{
			traitAggregationHelper.detach();
		}
		
		// Overrides
		//

		override protected function volumeChangeStart(newVolume:Number):void
		{
			applyVolumeToChildren(newVolume);
		}
		
		override protected function mutedChangeStart(newMuted:Boolean):void
		{
			applyMutedToChildren(newMuted);
		}
		
		override protected function panChangeStart(newPan:Number):void
		{
			applyPanToChildren(newPan);
		}
		
		// Internals
		//
		
		private function processAggregatedChild(child:MediaTraitBase):void
		{
			child.addEventListener(AudioEvent.MUTED_CHANGE,  onMutedChanged, 	false, 0, true);
			child.addEventListener(AudioEvent.PAN_CHANGE, 	 onPanChanged, 		false, 0, true);
			child.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChanged, 	false, 0, true);
			
			var audioTrait:AudioTrait = child as AudioTrait;
			
			if (traitAggregator.getNumTraits(MediaTraitType.AUDIO) == 1)
			{
				// The first added child's properties are applied to the
				// composite trait.
				pan 	= audioTrait.pan;
				muted 	= audioTrait.muted;
				volume  = audioTrait.volume;
			}
			else
			{
				// All subsequently added children inherit their properties
				// from the composite trait.
				audioTrait.pan 		= pan;
				audioTrait.muted	= muted;
				audioTrait.volume	= volume;
			}
		}

		private function processUnaggregatedChild(child:MediaTraitBase):void
		{
			// All we need to do is remove the listeners.  For both parallel
			// and serial media, unaggregated children have no bearing on
			// the properties of the composite trait.
			child.removeEventListener(AudioEvent.MUTED_CHANGE, 	onMutedChanged);
			child.removeEventListener(AudioEvent.PAN_CHANGE, 	onPanChanged);
			child.removeEventListener(AudioEvent.VOLUME_CHANGE,	onVolumeChanged);
		}
		
		private function onVolumeChanged(event:AudioEvent):void
		{
			// Changes from the child propagate to the composite trait.
			volume = (event.target as AudioTrait).volume;
		}

		private function onMutedChanged(event:AudioEvent):void
		{
			// Changes from the child propagate to the composite trait.
			muted = (event.target as AudioTrait).muted;
		}

		private function onPanChanged(event:AudioEvent):void
		{
			/// Changes from the child propagate to the composite trait.
			pan = (event.target as AudioTrait).pan;
		}
				
		private function applyVolumeToChildren(newVolume:Number):void
		{
			traitAggregator.forEachChildTrait
				(
				  function(mediaTrait:MediaTraitBase):void
				  {
				     AudioTrait(mediaTrait).volume = newVolume;
				  }
				, MediaTraitType.AUDIO
				);
		}
		
		private function applyMutedToChildren(newMuted:Boolean):void
		{
			traitAggregator.forEachChildTrait
				(
				  function(mediaTrait:MediaTraitBase):void
				  {
				     AudioTrait(mediaTrait).muted = newMuted;
				  }
				, MediaTraitType.AUDIO
				);
		}
		
		private function applyPanToChildren(newPan:Number):void
		{
			traitAggregator.forEachChildTrait
				(
				  function(mediaTrait:MediaTraitBase):void
				  {
				     AudioTrait(mediaTrait).pan = newPan;
				  }
				, MediaTraitType.AUDIO
				);
		}
		
		private var traitAggregator:TraitAggregator;
		private var traitAggregationHelper:TraitAggregationHelper;
	}
}