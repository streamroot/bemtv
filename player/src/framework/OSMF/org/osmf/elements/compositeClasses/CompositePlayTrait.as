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
	import org.osmf.events.PlayEvent;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	internal class CompositePlayTrait extends PlayTrait implements IReusable
	{
		/**
		 * Constructor.
		 * 
		 * @param traitAggregator The object which is aggregating all instances
		 * of the PlayTrait within this composite trait.
		 * @param mode The composition mode to which this composite trait
		 * should adhere.  See CompositionMode for valid values.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function CompositePlayTrait(traitAggregator:TraitAggregator, mode:String)
		{
			super();
			
			this.traitAggregator = traitAggregator;
			this.mode = mode;
			
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

		/**
		 * @private
		 */
		override protected function playStateChangeStart(newPlayState:String):void
		{
			if (newPlayState != playState && !playStateIsChanging)
			{
				// Prevent this from being reentrant.
				playStateIsChanging = true;
				
				if (mode == CompositionMode.PARALLEL)
				{
					// Invoke the appropriate method on all children.
					if (newPlayState == PlayState.PLAYING)
					{
						traitAggregator.invokeOnEachChildTrait("play", [], MediaTraitType.PLAY);
					}
					else if (newPlayState == PlayState.PAUSED)
					{
						traitAggregator.invokeOnEachChildTrait("pause", [], MediaTraitType.PLAY);
					}
					else // STOPPED
					{
						traitAggregator.invokeOnEachChildTrait("stop", [], MediaTraitType.PLAY);
					}
				}
				else // SERIAL
				{
					// We want to set the playState on the current child.  But doing
					// so could trigger events which would affect the state of this
					// trait, which might cause it to get out of sync (since this call
					// is generally followed by the set to the actual playState var).
					// It is the responsibility of this trait to ensure that it's own
					// state doesn't get out of sync.  It does this by remembering
					// the operation to invoke, and invoking it at the next "safe" time
					// (which is basically when the postProcess method gets called).
					deferredPlayTraitToSet = traitOfCurrentChild;
					deferredPlayStateToSet = newPlayState;
				}
				
				playStateIsChanging = false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function playStateChangeEnd():void
		{
			// Never dispatch the event while we're in the middle of
			// processing.
			if (playStateIsChanging == false)
			{
				super.playStateChangeEnd();
			}
			
			// If we have a deferred operation to complete, do so now.
			if (deferredPlayTraitToSet != null)
			{
				setPlayState(deferredPlayTraitToSet, deferredPlayStateToSet);
			}
			deferredPlayTraitToSet = null;
			deferredPlayStateToSet = null;
		}
		
		// Internals
		//
		
		private function processAggregatedChild(child:MediaTraitBase):void
		{
			child.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange, false, 0, true);
			child.addEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange, false, 0, true);

			var playTrait:PlayTrait = child as PlayTrait;
			
			if (mode == CompositionMode.PARALLEL)
			{
				if (traitAggregator.getNumTraits(MediaTraitType.PLAY) == 1)
				{
					// The first added child's properties are applied to the
					// composite trait.
					setPlayState(this, playTrait.playState);
				}
				else
				{
					// All subsequently added children inherit their properties
					// from the composite trait.
					setPlayState(playTrait, this.playState);
				}
				
				updateCanPauseState();
			}
			else if (child == traitOfCurrentChild)
			{
				// The first added child's properties are applied to the
				// composite trait.
				setPlayState(this, playTrait.playState);
				
				updateCanPauseState();
			}
		}

		private function processUnaggregatedChild(child:MediaTraitBase):void
		{
			child.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			child.removeEventListener(PlayEvent.CAN_PAUSE_CHANGE, onCanPauseChange);
			
			updateCanPauseState();
		}
		
		private function onPlayStateChange(event:PlayEvent):void
		{
			var playTrait:PlayTrait = event.target as PlayTrait;
			
			if (mode == CompositionMode.PARALLEL)
			{
				// The composition should reflect what its children do.
				var computedPlayState:String = playTrait.playState;
				
				// If this child reached the STOPPED state by virtue of
				// reaching the end, then we only want to set the composite
				// trait's state to STOPPED if all other children are
				// similarly STOPPED.
				if (computedPlayState == PlayState.STOPPED)
				{
					traitAggregator.forEachChildTrait
						(
							function(mediaTrait:PlayTrait):void
							{
								if (mediaTrait.playState != PlayState.STOPPED)
								{
									computedPlayState = mediaTrait.playState;
								}
							}
							, MediaTraitType.PLAY
						);
				}
				setPlayState(this, computedPlayState);
			}
			else if (playTrait == traitOfCurrentChild)
			{
				// The composition should reflect what its children do.
				setPlayState(this, playTrait.playState);
				
				// Typically, the CompositeTimeTrait will handle transitioning
				// from one child to the next based on the receipt of the
				// complete event.  However, if the current child
				// doesn't have the TimeTrait, then it obviously can't do so.
				// So we check here for that case.
				if (playTrait.playState == PlayState.STOPPED &&
					traitAggregator.listenedChild.hasTrait(MediaTraitType.TIME) == false)
				{
					// If the current child has another sibling ahead of it,
					// then the next sibling with a PlayTrait should be played.
					SerialElementTransitionManager.playNextPlayableChild
						( traitAggregator
						, null
						);
				}
			}
		}
		
		private function onCanPauseChange(event:PlayEvent):void
		{
			updateCanPauseState();
		}
		
		private function setPlayState(playTrait:PlayTrait, value:String):void
		{
			if (value != playTrait.playState)
			{
				if (value == PlayState.PLAYING)
				{
					playTrait.play();
				}
				else if (value == PlayState.PAUSED)
				{
					// If we can't pause, leave it alone.  The composition may
					// get out of sync, but that's acceptable.
					if (playTrait.canPause)
					{
						playTrait.pause();
					}
				}
				else // STOPPED
				{
					playTrait.stop();
				}
			}	
		}
		
		private function updateCanPauseState():void
		{
			if (mode == CompositionMode.PARALLEL)
			{
				// The composition can be paused if at least one child can be paused.
				var newCanPause:Boolean = false;
				traitAggregator.forEachChildTrait
					(
					  function(mediaTrait:MediaTraitBase):void
					  {
					     newCanPause ||= PlayTrait(mediaTrait).canPause;
					  }
					, MediaTraitType.PLAY
					);
				
				if (canPause != newCanPause)
				{
					setCanPause(newCanPause);
					
					// If the composite trait changes from pausable to unpausable
					// while it's paused, we need to get the composite trait's state
					// in sync with the state of its children (whether that be playing
					// or stopped).
					if (newCanPause == false && playState == PlayState.PAUSED)
					{
						var newPlayState:String;
						traitAggregator.forEachChildTrait
							(
							  function(mediaTrait:MediaTraitBase):void
							  {
							  	newPlayState ||= PlayTrait(mediaTrait).playState;
							  }
							, MediaTraitType.PLAY
							);
						if (newPlayState != null)
						{
							setPlayState(this, newPlayState);
						}
					} 
				}
			}
			else
			{
				setCanPause(traitOfCurrentChild.canPause);
			}
		}
		
		private function get traitOfCurrentChild():PlayTrait
		{
			return   traitAggregator.listenedChild
				   ? traitAggregator.listenedChild.getTrait(MediaTraitType.PLAY) as PlayTrait
				   : null;
		}

		private var mode:String;
		private var traitAggregator:TraitAggregator;
		private var traitAggregationHelper:TraitAggregationHelper;
		private var playStateIsChanging:Boolean;
		private var deferredPlayTraitToSet:PlayTrait;
		private var deferredPlayStateToSet:String;
	}
}