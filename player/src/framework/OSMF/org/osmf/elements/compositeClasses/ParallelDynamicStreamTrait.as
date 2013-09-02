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
	import __AS3__.vec.Vector;
	
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;

	/**
	 * ParallelDynamicStreamTrait is the composite trait for DynamicStreamTrait.
	 * If a child doesn't have the same bitrate as an another, the closest match will be chosen
	 * when switching between bitrates.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */ 
	internal class ParallelDynamicStreamTrait extends DynamicStreamTrait
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function ParallelDynamicStreamTrait(traitAggregator:TraitAggregator)
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
		override public function getBitrateForIndex(index:int):Number
		{
			if (index >= bitrates.length || index < 0)
			{
				throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
			}
			
			return bitrates[index];
		}
		
		/**
		 * @private
		 */
		override protected function autoSwitchChangeStart(value:Boolean):void
		{
			if (autoSwitchIsChanging == false)
			{
				autoSwitchIsChanging = true;
				
				traitAggregator.forEachChildTrait(
					function(mediaTrait:DynamicStreamTrait):void
					{
						 mediaTrait.autoSwitch = value;
					}
					,   MediaTraitType.DYNAMIC_STREAM
					);
					
				autoSwitchIsChanging = false;
			}
		}
		
		override protected function autoSwitchChangeEnd():void
		{
			if (autoSwitchIsChanging == false)
			{
				super.autoSwitchChangeEnd();
			}
		}
		
		/**
		 * @private
		 */ 
		override protected function switchingChangeStart(newSwitching:Boolean, index:int):void
		{
			if (newSwitching)
			{
				traitAggregator.forEachChildTrait(
					function(mediaTrait:DynamicStreamTrait):void
					{	
						var desiredBitRate:Number = bitrates[index];	
						var childIndex:Number;		
						for (childIndex = 0; childIndex <= mediaTrait.maxAllowedIndex; childIndex++)
						{		
							var childBitRate:Number = mediaTrait.getBitrateForIndex(childIndex);
												
							if (childBitRate == desiredBitRate)								   
							{
								break;
							}									
							else if (childBitRate > desiredBitRate)
							{
								childIndex--;							
								break;
							}				
						}							
						// If we made it here, the last item is the correct stream
						var targetIndex:int = Math.max(0, Math.min(childIndex, mediaTrait.maxAllowedIndex)); 
						if (mediaTrait.currentIndex != targetIndex)
						{
							numChildrenSwitching++;
							mediaTrait.switchTo(targetIndex);
						}													
					}
			    	, MediaTraitType.DYNAMIC_STREAM);
			    	
			    setCurrentIndex(index);
			}
		}
		
		/**
		 * @private
		 */ 
		override protected function switchingChangeEnd(index:int):void
		{
			super.switchingChangeEnd(index);
			
			// If a switch didn't trigger the switch of any children, or if all
			// children finished their switches immediately, then we can
			// terminate the switch now.
			if (switching == true && numChildrenSwitching == 0)
			{
				setSwitching(false, index);
			}
		}
		
		/**
		 * @private
		 */ 
		private function processAggregatedChild(child:MediaTraitBase):void
		{			
			var aggregatedBR:int = 0;
			var childTrait:DynamicStreamTrait = DynamicStreamTrait(child);
			if (traitAggregator.getNumTraits(MediaTraitType.DYNAMIC_STREAM) == 1)
			{
				autoSwitch = childTrait.autoSwitch;				
			}
			else
			{
				childTrait.autoSwitch = autoSwitch;
			}
						
			mergeChildRates(childTrait);
			
			child.addEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, recomputeIndices);
			child.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);
			child.addEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);
			
			setNumDynamicStreams(bitrates.length);
			maxAllowedIndex = bitrates.length - 1; 			
		}
		
		/**
		 * @private
		 */ 
		private function processUnaggregatedChild(child:MediaTraitBase):void
		{	
			child.removeEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, recomputeIndices);
			child.removeEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onSwitchingChange);
			child.removeEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);

			recomputeIndices();	
		}
		
		/**
		 * Rebuilds the child bitrates from the children's traits.
		 * Updates the max index based on the children's max indices.
		 * 
		 * @returns True if there were changes to the bitrate table.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		private function rebuildBitRateTable():Boolean
		{
			// Rebuild bitrate table.
			var oldBitrates:Vector.<Number> = bitrates;
			bitrates = new Vector.<Number>;
								
			traitAggregator.forEachChildTrait(
				function(mediaTrait:DynamicStreamTrait):void
				{	
					mergeChildRates(mediaTrait);							
				}
			,   MediaTraitType.DYNAMIC_STREAM
			);
			
			if (bitrates.length > 0)
			{
				setNumDynamicStreams(bitrates.length);
				maxAllowedIndex = bitrates.length -1;
			}
			
			// Currently doesn't detect in place changes.
			// since this is never called after an in place change, this check is good enough.
			return oldBitrates.length != bitrates.length;
		}
		
		/**
		 * Add a new child to the bitrate table.  Insertions are made in
		 * sorted order.
		 * 
		 * @returns True if the indices changed.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		private function mergeChildRates(child:DynamicStreamTrait):Boolean
		{	
			var aggregatedIndex:int = 0;
			var indicesChanged:Boolean = false;
						
			for (var childBR:int = 0; childBR <= child.maxAllowedIndex; ++childBR)
			{
				var rate:Number = child.getBitrateForIndex(childBR);
				
				if (bitrates.length <= aggregatedIndex) // Add it to the end
				{
					indicesChanged = true;
					bitrates.push(rate);
					aggregatedIndex++;					
				} 
				else if (bitrates[aggregatedIndex] == rate)
				{
					continue;  // No operation for rates that already are in the list. 
				}			
				else if (bitrates[aggregatedIndex] < rate)
				{
				 	aggregatedIndex++;			
				 	childBR--;  // backup one, we need to keep going through the aggregatedBR's until we find a spot.	 	
				}
				else  // bitrate is smaller than the current bitrate.
				{
					indicesChanged = true;
					bitrates.splice(aggregatedIndex, 0, rate);
				}
			}	
			return indicesChanged;
		}
		
		/**
		 * Rebuilds the bitrate table and switches to the appropriate bit rate.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		private function recomputeIndices(event:DynamicStreamEvent = null):void
		{			
			var oldBitRate:Number = bitrates[currentIndex];
			if (rebuildBitRateTable()) // Update current index, and dispatch event if indices changed.
			{
				if (!autoSwitch)
				{			
					var highestBitRate:Number = 0;		
					traitAggregator.forEachChildTrait(
						function(mediaTrait:DynamicStreamTrait):void
						{	
							highestBitRate = Math.max(mediaTrait.getBitrateForIndex(mediaTrait.currentIndex), highestBitRate);							
						}
						,   MediaTraitType.DYNAMIC_STREAM);
					var newBIndex:Number = 0;
					while (highestBitRate != bitrates[newBIndex])
					{
						newBIndex++;								
					}	
					setCurrentIndex(newBIndex);					
				}
			}								
		}
				
		/**
		 * Handle the child trait changing.  Collapse multiple events into a
		 * single event when switching multiple children simultaneously.   
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		private function onSwitchingChange(event:DynamicStreamEvent):void
		{
			if (event.switching == false && numChildrenSwitching > 0)
			{
				numChildrenSwitching--;
				
				if (numChildrenSwitching == 0 && switching == true)
				{
					setSwitching(false, currentIndex);
				}
			}
		}
		
		private function onAutoSwitchChange(event:DynamicStreamEvent):void
		{
			// Propagate to the composite trait (and thus all children too).
			autoSwitch = event.autoSwitch;
		}
		
		private var traitAggregator:TraitAggregator;
		private var traitAggregationHelper:TraitAggregationHelper;
		private var bitrates:Vector.<Number> = new Vector.<Number>;
		private var autoSwitchIsChanging:Boolean = false;
		private var numChildrenSwitching:int = 0;
	}
}