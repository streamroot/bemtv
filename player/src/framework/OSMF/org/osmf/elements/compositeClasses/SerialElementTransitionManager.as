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
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	/**
	 * @private
	 * 
	 * Helper class for managing transitions from one child of
	 * a SerialElement to another.
	 */
	internal class SerialElementTransitionManager
	{
		/**
		 * Plays the next playable child that follows the current child,
		 * using the TraitAggregator as the source of available children.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static function playNextPlayableChild
			( traitAggregator:TraitAggregator
			, noNextPlayableChildCallback:Function
			):void
		{
			var currentChild:MediaElement = traitAggregator.listenedChild;
			
			// Make a list of all children that follow the current
			// child.
			var nextChildren:Array = getNextChildren(traitAggregator, currentChild);
			
			// Use a TraitLoader to find the next child that has the
			// PlayTrait, loading along the way if necessary.
			var traitLoader:TraitLoader = new TraitLoader();
			traitLoader.addEventListener(TraitLoaderEvent.TRAIT_FOUND, onTraitFound);
			traitLoader.findOrLoadMediaElementWithTrait(nextChildren, MediaTraitType.PLAY);
			
			function onTraitFound(event:TraitLoaderEvent):void
			{
				traitLoader.removeEventListener(TraitLoaderEvent.TRAIT_FOUND, onTraitFound);
				
				// If we do have a next playable child, then we play it.
				// Otherwise we're done playing.
				if (event.mediaElement)
				{
					var traitOfNextPlayableChild:PlayTrait = event.mediaElement.getTrait(MediaTraitType.PLAY) as PlayTrait;

					// We want to set the new current child, and then initiate
					// playback.  However, it's possible that the act of setting
					// the new current child will automatically trigger playback
					// (for example if the child is placed in parallel to an
					// already-playing element).  In such a case, we obviously
					// don't want to play it a second time.
					//
					// Unfortunately, it's not a simple matter of checking the
					// PlayTrait.playState property, because it's possible that
					// the play happened instantaneously (i.e. playState wouldn't
					// be PLAYING).  The most surefire way of detecting
					// whether the play actually occurred is to listen for an
					// event.
					var playbackInitiated:Boolean = false;
					traitOfNextPlayableChild.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
					function onPlayStateChange(event:PlayEvent):void
					{
						if (event.playState == PlayState.PLAYING)
						{
							playbackInitiated = true;
						}
					}
					
					// Set the current child, this is where the playback might
					// get automatically triggered.			
					traitAggregator.listenedChild = event.mediaElement;
					
					// No need to listen for the event anymore.
					traitOfNextPlayableChild.removeEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);

					if (playbackInitiated == false)
					{
						traitOfNextPlayableChild.play();
					}
					else
					{
						// Just because playback was initiated doesn't mean
						// we're done.  It's possible that the playback
						// occurred synchronously and already completed, in
						// which case we should trigger playback of the next
						// child (if it's not playing already).  This should
						// only happen if the child lacks the TimeTrait.
						if (traitOfNextPlayableChild.playState == PlayState.STOPPED &&
							traitAggregator.listenedChild.hasTrait(MediaTraitType.TIME) == false)
						{
							playNextPlayableChild
								( traitAggregator
								, noNextPlayableChildCallback
								);
						}
					}
				}
				else
				{
					// There's no next playable child.  However, we should still
					// move to the next child (which isn't playable).
					if (nextChildren.length > 0)
					{
						traitAggregator.listenedChild = nextChildren[0] as MediaElement;
					}

					if (noNextPlayableChildCallback != null)
					{
						noNextPlayableChildCallback();
					}
				}
			}
		}
		
		/**
		 * Returns all children that follow the specified currentChild,
		 * using the specified TraitAggregator as the source of all
		 * children.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private static function getNextChildren(traitAggregator:TraitAggregator, currentChild:MediaElement):Array
		{
			var nextChildren:Array = [];
			
			var reachedCurrentChild:Boolean = false;
			for (var i:int = 0; i < traitAggregator.numChildren; i++)
			{
				var child:MediaElement = traitAggregator.getChildAt(i);
				if (currentChild == child)
				{
					reachedCurrentChild = true;
				}
				else if (reachedCurrentChild)
				{
					nextChildren.push(child);
				}
			}
			
			return nextChildren;
		}
	}
}