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
	import org.osmf.events.BufferEvent;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * Implementation of BufferTrait which can be a composite media trait.
	 * 
	 * For both parallel and serial media elements, a composite buffer trait
	 * keeps all buffer properties in sync for the composite element and its
	 * children.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class CompositeBufferTrait extends BufferTrait implements IReusable
	{
		public function CompositeBufferTrait(traitAggregator:TraitAggregator, mode:String)
		{
			super();
			
			bufferTime					= 0;
			bufferTimeFromChildren		= true;
			settingBufferTime			= false;
			this.mode					= mode;
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
		override public function get bufferLength():Number
		{
			var length:Number;
			
			if (mode == CompositionMode.PARALLEL)
			{
				// In parallel,
				//
				// When none of the child trait is in the condition of bufferLength < bufferTime, 
				// the bufferLength of the trait is the average of the bufferLength values of its 
				// children. 
				// 
				// When at least one of the children is in the condition of bufferLength < bufferTime, 
				// the composite trait calculates its bufferLength as follows. For each child trait 
				// with bufferLength < bufferTime, the composite trait takes the actual bufferLength. 
				// For the rest of the children, the composite trait takes its bufferTime as its 
				// current bufferLength. Then the composite trait takes the average of the current 
				// bufferLength of the children (as described) as its bufferLength.
				var totalUnadjustedBufferLength:Number	= 0;
				var totalAdjustedBufferLength:Number	= 0;
				var needAdjustment:Boolean				= false;
				
				traitAggregator.forEachChildTrait
					(
					  function(mediaTrait:MediaTraitBase):void
					  {
					  	var bufferTrait:BufferTrait = BufferTrait(mediaTrait);
					  	if (bufferTrait.bufferLength < bufferTrait.bufferTime)
					  	{
					  		totalUnadjustedBufferLength	+= bufferTrait.bufferLength;
					  		totalAdjustedBufferLength	+= bufferTrait.bufferLength;
					  		needAdjustment = true;
					  	}
					  	else
					  	{
					  		totalUnadjustedBufferLength	+= bufferTrait.bufferLength;
					  		totalAdjustedBufferLength	+= bufferTrait.bufferTime;
					  	}
					  }
					, MediaTraitType.BUFFER
					);
					
				length = (needAdjustment? totalAdjustedBufferLength : totalUnadjustedBufferLength)
						/ traitAggregator.getNumTraits(MediaTraitType.BUFFER);
			}
			else
			{
				// In serial, the values of bufferLength of the composite trait is taken from the curent 
				// child trait.
				length =  (traitOfCurrentChild != null)? traitOfCurrentChild.bufferLength : 0;
			}
			
			return length;
		}
		
		override public function set bufferTime(value:Number):void
		{
			if (bufferTime == value)
			{
				return;
			}
			
			settingBufferTime = true;
			
			// Set new bufferTime to each child who supports BufferTrait 
			traitAggregator.forEachChildTrait
				(
				  function(mediaTrait:MediaTraitBase):void
				  {
				     BufferTrait(mediaTrait).bufferTime = value;
				  }
				, MediaTraitType.BUFFER
				);

			super.bufferTime = value;
			
			bufferTimeFromChildren = false;
			settingBufferTime = false;
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

		private function processAggregatedChild(child:MediaTraitBase):void
		{
			onBufferingChanged();
			
			if (bufferTimeFromChildren)
			{
				onBufferTimeChanged();
			}
			else if (child is BufferTrait)
			{
				settingBufferTime = true;
				(child as BufferTrait).bufferTime = bufferTime;
				settingBufferTime = false;
			}

			child.addEventListener(BufferEvent.BUFFERING_CHANGE,	onBufferingChanged,		false, 0, true);
			child.addEventListener(BufferEvent.BUFFER_TIME_CHANGE,	onBufferTimeChanged,	false, 0, true);
		}

		private function processUnaggregatedChild(child:MediaTraitBase):void
		{
			onBufferingChanged();
			if (bufferTimeFromChildren)
			{
				onBufferTimeChanged();
			}

			child.removeEventListener(BufferEvent.BUFFERING_CHANGE,		onBufferingChanged);
			child.removeEventListener(BufferEvent.BUFFER_TIME_CHANGE,	onBufferTimeChanged);
		}
		
		private function onBufferingChanged(event:BufferEvent=null):void
		{
			var newBufferingState:Boolean = checkBuffering();
			if (newBufferingState != buffering)
			{
				setBuffering(newBufferingState);
			}
		}
		
		private function onBufferTimeChanged(event:BufferEvent=null):void
		{
			// The composite trait is in the middle of setting the bufferTime of each child.
			// So it may expect some bufferTimeChange events dispatched from the children. 
			// But under the circumstance, all these events should be ignored.
			if (settingBufferTime)
			{
				return;
			}
			
			var oldBufferTime:Number = bufferTime;
			var newBufferTime:Number = calculateBufferTime();
			bufferTimeFromChildren = true;
			if (oldBufferTime != newBufferTime)
			{
				super.bufferTime = newBufferTime;
			}
		}
		
		private function calculateBufferTime():Number
		{
			var time:Number = 0;
			
			if (mode == CompositionMode.PARALLEL)
			{
				// In parallel case, the bufferTime is the average of the bufferTime of the children.
				traitAggregator.forEachChildTrait
					(
					  function(mediaTrait:MediaTraitBase):void
					  {
					     time += BufferTrait(mediaTrait).bufferTime;
					  }
					, MediaTraitType.BUFFER
					);
				if (time > 0)
				{
					time = time / traitAggregator.getNumTraits(MediaTraitType.BUFFER);
				}
			}
			else
			{
				// In serial case, the bufferTime is taken from the current child.
				// If the current child does not support BufferTrait, return zero.
				time = traitOfCurrentChild != null ? traitOfCurrentChild.bufferTime : 0;
			}
			
			return time;
		}
		
		private function checkBuffering():Boolean
		{
			var isBuffering:Boolean = false;
			if (mode == CompositionMode.PARALLEL)
			{
				// In parallel case, buffering is true when at least one child is buffering.
				traitAggregator.forEachChildTrait
					(
					  function(mediaTrait:MediaTraitBase):void
					  {
					     isBuffering ||= BufferTrait(mediaTrait).buffering;
					  }
					, MediaTraitType.BUFFER
					);
			}
			else
			{
				// In serial case, buffering state is taken from that of the current child.
				// If the current child does not support BufferTrait, return false.
				isBuffering = traitOfCurrentChild != null? traitOfCurrentChild.buffering : false;
			}	
			
			return isBuffering;
		}
		
		private function get traitOfCurrentChild():BufferTrait
		{
			return   traitAggregator.listenedChild
				   ? traitAggregator.listenedChild.getTrait(MediaTraitType.BUFFER) as BufferTrait
				   : null;			
		}

		private var traitAggregator:TraitAggregator;
		private var traitAggregationHelper:TraitAggregationHelper;
		private var mode:String;		
		private var bufferTimeFromChildren:Boolean;
		private var settingBufferTime:Boolean;
	}
}