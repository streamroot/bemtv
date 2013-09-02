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
	import org.osmf.elements.SerialElement;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.TimeTrait;

	/**
	 * Implementation of TimeTrait which can be a composite media trait.
	 * 
	 * For parallel media elements, the composite trait represents a timeline
	 * that encapsulates the timeline of all children.  Its duration is the
	 * maximum of the durations of all children.  Its currentTime is kept in sync
	 * for all children (with the obvious caveat that a child's currentTime will
	 * never be greater than its duration).
	 * 
	 * For serial elements, the composite trait represents a timeline that
	 * encapsulates the timeline of all children.  Its duration is the sum of
	 * the durations of all children.  Its currentTime is the sum of the currentTimes
	 * of the first N fully complete children, plus the currentTime of the next
	 * child.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class CompositeTimeTrait extends TimeTrait implements IReusable
	{
		/**
		 * Constructor.
		 * 
		 * @param traitAggregator The object which is aggregating all instances
		 * of the TimeTrait within this composite trait.
		 * @param mode The composition mode to which this composite trait
		 * should adhere.  See CompositionMode for valid values.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function CompositeTimeTrait(traitAggregator:TraitAggregator, mode:String, owner:MediaElement)
		{
			super();
			
			this.mode = mode;
			this.traitAggregator = traitAggregator;
			this.owner = owner;
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

		override public function dispose():void
		{
		}

		/**
		 * @private
		 */		
		override public function get currentTime():Number
		{
			updateCurrentTime();
			
			return super.currentTime;
		}
		
		override protected function signalComplete():void
		{
			// The base class can cause this method to get called, sometimes
			// inappropriately for serial elements, so we need to verify that
			// it's truly complete.
			if (	mode == CompositionMode.PARALLEL
				||  isSerialComplete() 
			   )
			{
				super.signalComplete()
			}
		}
		
		private function isSerialComplete():Boolean
		{
			// A serial element is only complete if it's truly at the end.
			//
			
			var childTimeTrait:TimeTrait = traitAggregator.listenedChild.getTrait(MediaTraitType.TIME) as TimeTrait;
			
			// Conditions in which it's not at the end:
			// 1) If currentTime == duration because we don't yet have the duration
			//    for the next child.
			// 2) If the next child doesn't have a duration yet (FM-303).
			var result:Boolean =
					traitAggregator.getChildIndex(traitAggregator.listenedChild) == traitAggregator.numChildren - 1
				&&	childTimeTrait.duration > 0
				&&	!isNaN(childTimeTrait.duration);
			
			// 3) If the last child is itself a SerialElement, then we need to 
			// recursively apply the same rule checks, in case it appears to be
			// complete but really isn't (FM-707).
			if (	result
				&&	childTimeTrait is CompositeTimeTrait
				&&	traitAggregator.listenedChild is SerialElement
			   )
			{
				result = CompositeTimeTrait(childTimeTrait).isSerialComplete();
			}
				
			return result;
		}
				
		// Internal
		//
		
		/**
		 * @private
		 */
		private function processAggregatedChild(child:MediaTraitBase):void
		{
			child.addEventListener(TimeEvent.DURATION_CHANGE,  	onDurationChanged, 	false, 0, true);
			child.addEventListener(TimeEvent.COMPLETE, 			onComplete, 		false, 0, true);
			
			updateDuration();
			updateCurrentTime();
		}

		/**
		 * @private
		 */
		private function processUnaggregatedChild(child:MediaTraitBase):void
		{
			child.removeEventListener(TimeEvent.DURATION_CHANGE, 	onDurationChanged);
			child.removeEventListener(TimeEvent.COMPLETE, 			onComplete);
			
			updateDuration();
			updateCurrentTime();
		}

		private function onDurationChanged(event:TimeEvent):void
		{
			updateDuration();
		}

		private function onComplete(event:TimeEvent):void
		{
			var timeTrait:TimeTrait = event.target as TimeTrait;
			
			if (mode == CompositionMode.PARALLEL)
			{
				// If every child has reached their duration, then we should
				// dispatch the complete event.
				var allHaveReachedDuration:Boolean = true;
				traitAggregator.forEachChildTrait
					(
						function(mediaTrait:MediaTraitBase):void
						{
							var iterTimeTrait:TimeTrait = TimeTrait(mediaTrait);
							
							// Assume that the child that fired the event has
							// finished.
							if (iterTimeTrait != timeTrait &&
								iterTimeTrait.currentTime < iterTimeTrait.duration)
							{
								allHaveReachedDuration = false;
							}
						}
						, MediaTraitType.TIME
					);
				
				if (allHaveReachedDuration)
				{
					// It is critical to use super.currentTime instead of currentTime property of the class
					// because currentTime of this class will call updateCurrentTime which may accidentally
					// dispatch TimeEvent.COMPLETE. 
					if (super.currentTime != this.duration)	
					{
						this.updateCurrentTime();				
					}
					else
					{
						dispatchEvent(new TimeEvent(TimeEvent.COMPLETE));
					}
				}
			}
			else // SERIAL
			{
				if (timeTrait == traitOfCurrentChild)
				{
					// If the composite element has the PlayTrait and the
					// current child has another sibling ahead of it, then
					// the next sibling with a PlayTrait should be played.
					var playTrait:PlayTrait = owner.getTrait(MediaTraitType.PLAY) as PlayTrait;
					if (playTrait != null)
					{
						// Note that we don't check whether to dispatch the 
						// complete event until we determine that
						// there's no more playable children -- otherwise we'd
						// almost certainly dispatch it when it shouldn't be
						// dispatched since subsequent children are likely to
						// lack the temporal trait until they're loaded.
						SerialElementTransitionManager.playNextPlayableChild
							( traitAggregator
							, checkDispatchCompleteEvent
							);
					}
					else
					{
						checkDispatchCompleteEvent();
					}
				}
			}
		}
		
		private function checkDispatchCompleteEvent():void
		{
			// If the current child is the last temporal child, then we should
			// dispatch the complete event.
			var nextChild:MediaElement = 
				traitAggregator.getNextChildWithTrait
					( traitAggregator.listenedChild
					, MediaTraitType.TIME
					);
			
			if (nextChild == null)
			{				
				super.signalComplete();
			}
		}
		
		private function updateDuration():void
		{
			var newDuration:Number = 0;
			var hasChildWithDuration:Boolean = false;
			
			traitAggregator.forEachChildTrait
				(
					function(mediaTrait:MediaTraitBase):void
				  	{
				  		var childDuration:Number = TimeTrait(mediaTrait).duration;
				  		if (!isNaN(childDuration))
				  		{
				  			hasChildWithDuration = true;
				  			
					  		if (mode == CompositionMode.PARALLEL)
					  	 	{ 
					  	 		// The duration is the max of all child durations.
					     	 	newDuration = Math.max(newDuration, childDuration);
					     	}
					     	else // SERIAL
					     	{
					     	 	// The duration is the sum of all child durations.
					     	 	newDuration += childDuration;
					     	}
					   }
				  	}
					, MediaTraitType.TIME
				);

			setDuration(hasChildWithDuration ? newDuration : NaN);
		}
		
		private function updateCurrentTime():void
		{
			var newCurrentTime:Number = 0;
			var hasChildWithCurrentTime:Boolean = false;
			var serialCurrentTimeCalculated:Boolean = false;
			
			traitAggregator.forEachChildTrait
				(
					function(mediaTrait:MediaTraitBase):void
				  	{
				  		var childCurrentTime:Number = TimeTrait(mediaTrait).currentTime;
				  		if (isNaN(childCurrentTime))
				  		{
				  			childCurrentTime = 0;
				  		}
				  		else
				  		{
				  			hasChildWithCurrentTime = true;
				  		}
				  		
				  		if (mode == CompositionMode.PARALLEL)
				  	 	{
			  	 	 		// The currentTime is the max of all child currentTimes.
			     	 		newCurrentTime = Math.max(newCurrentTime, childCurrentTime);
			     	 	}
			     	 	else // SERIAL
			     	 	{
							// The currentTime is the sum of all durations up to the
							// current child, plus the currentTime of the current
							// child.
					  	 	if (!serialCurrentTimeCalculated)
					  	 	{
						  	 	if (mediaTrait == traitOfCurrentChild)
						  	 	{
						  	 	 	newCurrentTime += childCurrentTime;
						  	 	
						  	 	 	serialCurrentTimeCalculated = true;
						  	 	}
						  	 	else
						  	 	{
						  	 		var duration:Number = TimeTrait(mediaTrait).duration;
						  	 		if (!isNaN(duration))
						  	 		{
						  	 	 		newCurrentTime += duration;
						  	 	 	}
						  	 	}
						 	}
					 	}
				  	}
					, MediaTraitType.TIME
				);

			setCurrentTime(hasChildWithCurrentTime ? newCurrentTime : NaN);
		}

		private function get traitOfCurrentChild():TimeTrait
		{
			return   traitAggregator.listenedChild
				   ? traitAggregator.listenedChild.getTrait(MediaTraitType.TIME) as TimeTrait
				   : null;
		}
		
		private var traitAggregator:TraitAggregator;
		private var traitAggregationHelper:TraitAggregationHelper;
		private var mode:String;
		private var owner:MediaElement;
	}
}