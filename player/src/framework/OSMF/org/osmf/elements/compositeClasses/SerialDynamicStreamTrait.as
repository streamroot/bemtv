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
	import flash.events.Event;
	
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;

	/**
	 * @private
	 * 
	 * The SerialDynamicStreamTrait aggregates DynamicStreamTraits in serial, acting as a single
	 * trait.  This trait will match settings between child traits when switching between children.
	 */ 
	internal class SerialDynamicStreamTrait extends DynamicStreamTrait implements IReusable
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function SerialDynamicStreamTrait(traitAggregator:TraitAggregator)
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
			return traitOfCurrentChild.getBitrateForIndex(index);
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
		
		/**
		 * @private
		 */
		override protected function autoSwitchChangeEnd():void
		{
			// Propagate to the current child.
			traitOfCurrentChild.autoSwitch = autoSwitch;

			super.autoSwitchChangeEnd();
		}

		/**
		 * @private
		 */
		override protected function switchingChangeEnd(index:int):void
		{
			if (switching && !preventSwitchingChangePropagate)
			{
				// Propagate to the current child.
				traitOfCurrentChild.switchTo(index);
			}

			super.switchingChangeEnd(index);
		}
		
		/**
		 * @private
		 * 
		 * Adds the child as the current listened child.  Sets the autoswitch, property to 
		 * carry over from the previous child.  If autoswitch is false, attempts to match the bitrate
		 * for the next media element.
		 */ 
		private function processAggregatedChild(child:MediaTraitBase):void
		{		
			if (child == traitOfCurrentChild)
			{
				var dsTrait:DynamicStreamTrait = child as DynamicStreamTrait;
				
				setNumDynamicStreams(dsTrait.numDynamicStreams);
				maxAllowedIndex = dsTrait.maxAllowedIndex;
				autoSwitch = dsTrait.autoSwitch;

				if (!dsTrait.autoSwitch)
				{					
					for (var i:Number = 0; i <= dsTrait.maxAllowedIndex; i++)
					{						
						if (dsTrait.getBitrateForIndex(i) > getBitrateForIndex(currentIndex))							
						{														
							dsTrait.switchTo(Math.max(i-1, 0));	
							break;	
						}	
						else if (dsTrait.getBitrateForIndex(i) == getBitrateForIndex(currentIndex) ||
								 i == dsTrait.maxAllowedIndex)
						{																								
							dsTrait.switchTo(i);	
							break;	
						}									 
					}					
				}
				
				child.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE,  onSwitchingChange);	
				child.addEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, redispatchEvent);					
				child.addEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);
			}	
		}
			
		private function processUnaggregatedChild(child:MediaTraitBase):void
		{				
			child.removeEventListener(DynamicStreamEvent.SWITCHING_CHANGE,  onSwitchingChange);	
			child.removeEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, redispatchEvent);
			child.removeEventListener(DynamicStreamEvent.AUTO_SWITCH_CHANGE, onAutoSwitchChange);
		}
		
		private function redispatchEvent(event:Event):void
		{
			dispatchEvent(event.clone());
		}
		
		private function onAutoSwitchChange(event:DynamicStreamEvent):void
		{
			// Propagate to composite trait.
			autoSwitch = event.autoSwitch;
		}
		
		private function onSwitchingChange(event:DynamicStreamEvent):void
		{
			// Propagate to composite trait.
			preventSwitchingChangePropagate = true;
			setSwitching(event.switching, traitOfCurrentChild.currentIndex);
			preventSwitchingChangePropagate = false;
		}
		
		private function get traitOfCurrentChild():DynamicStreamTrait
		{
			return   traitAggregator.listenedChild
				   ? traitAggregator.listenedChild.getTrait(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait
				   : null;
		}
		
		private var traitAggregator:TraitAggregator;
		private var traitAggregationHelper:TraitAggregationHelper;
		private var preventSwitchingChangePropagate:Boolean;
	}
}