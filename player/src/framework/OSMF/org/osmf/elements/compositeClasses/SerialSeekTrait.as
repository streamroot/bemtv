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
	
	import org.osmf.events.SeekEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;

	/**
	 * Implementation of SeekTrait which can be a composite media trait.
	 * 
	 * In the serial case, the seek may:
	 * <ul> seek within the current child
	 * <ul> seek out of the current child and seek backward
	 * <ul> seek out of the current child and seek forward
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class SerialSeekTrait extends CompositeSeekTrait
	{
		public function SerialSeekTrait(traitAggregator:TraitAggregator, owner:MediaElement)
		{
			super(traitAggregator, CompositionMode.SERIAL, owner);
			
			this.owner = owner;
		}
		
		
		/**
		 * @private
		 */
		override protected function doSeek(seekOp:CompositeSeekOperationInfo):void
		{
			var serialSeek:SerialSeekOperationInfo = seekOp as SerialSeekOperationInfo;
			var childSeekTrait:SeekTrait = serialSeek.fromChild.getTrait(MediaTraitType.SEEK) as SeekTrait;
			
			if (serialSeek.fromChild == serialSeek.toChild)
			{
				readyToExitSeekingState = true;
				
				// This is the case where the seek is within the current child.
				childSeekTrait.seek(serialSeek.toChildTime);
			}
			else
			{
				// Now, the composite is going to do a seek that crosses multiple children.
				// The order of operations is as follows:
				// 1) Seek any required in-between children to the appropriate time.
				// 2) Seek the targeted child to the appropriate time.
				// 3) Seek the previous current child to the appropriate time.
				// 4) Set the new current child to be the targeted child.
				//
				// The reason for this order is to ensure that we seek all non-current
				// children *first*, and the current child *last*, so that we trigger
				// events last.
				//
				// Note that we prevent ourselves from exiting the seeking state until
				// we've completed all but the last operation.
				
				crossChildrenSeeking = true;
				allCrossChildrenSeeksInitiated = false;
				readyToExitSeekingState = false;
				
				// Remember the current state so that we can reapply it after the seek.
				var previousPlayState:String = getCompositePlayState();
							
				// Since the playhead seeks out of the child, the child needs to be stopped.
				var childPlayTrait:PlayTrait = serialSeek.fromChild.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if (childPlayTrait != null)
				{
					childPlayTrait.stop();
				}
								
				var childSeekTargetTime:Number;
				
				// Do the seek out of the current child first.
				if (serialSeek.seekForward)
				{
					// Seeking forward means to move the playhead to the end.
					var childTimeTrait:TimeTrait = serialSeek.fromChild.getTrait(MediaTraitType.TIME) as TimeTrait;
					childSeekTargetTime = childTimeTrait.duration;
				}
				else
				{
					// Place all in-between children at the start.
					for each (var inBetweenChild:SerialElementSegment in serialSeek.inBetweenChildren)
					{
						if (inBetweenChild.mediaElement.hasTrait(MediaTraitType.SEEK))
						{
							var inBetweenSeekTrait:SeekTrait = inBetweenChild.mediaElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
							if (inBetweenSeekTrait.canSeekTo(0))
							{
								inBetweenSeekTrait.seek(0);
							}
						}
					}
					
					// Seeking backward means to move the playhead to the beginning.
					childSeekTargetTime = 0;
				}

				// Now the composite does the seek into another child, where the destiny of the seek is.
				var nextSeekTrait:SeekTrait = serialSeek.toChild.getTrait(MediaTraitType.SEEK) as SeekTrait;
				nextSeekTrait.seek(serialSeek.toChildTime);

				// For forward seeks, set the current child before seeking the old
				// current child.  This ensures that a seek to the end doesn't trigger
				// playback of the next child.
				if (serialSeek.seekForward)
				{
					// Next, update our current child to the target child.
					traitAggregator.listenedChild = serialSeek.toChild;
					
					// We're not ready to exit the seeking state until we initiate
					// the last operation.  On a seek forward, the last operation
					// is the last seek (see below).
					readyToExitSeekingState = true;
				}
				
				// Now, seek the previously current child to the appropriate time.
				allCrossChildrenSeeksInitiated = true;
				childSeekTrait.seek(childSeekTargetTime);
				
				if (serialSeek.seekForward == false)
				{
					// We're not ready to exit the seeking state until we initiate
					// the last operation.  On a seek back, the last operation
					// is the setting of the new current child (see below).
					readyToExitSeekingState = true;
					
					traitAggregator.listenedChild = serialSeek.toChild;
				}
				
				if (!isNaN(exitSeekingStateTime))
				{
					setSeeking(false, exitSeekingStateTime);
					
					exitSeekingStateTime = NaN;
				}
				
				var playTrait:PlayTrait = owner.getTrait(MediaTraitType.PLAY) as PlayTrait;
				if (playTrait != null)
				{
					if (previousPlayState == PlayState.PLAYING)
					{
						playTrait.play();
					}
					else if (previousPlayState == PlayState.PAUSED && playTrait.canPause)
					{
						playTrait.pause();
					}
				}
			}
		}
		
		/**
		 * @private
		 */
		override protected function prepareSeekOperationInfo(time:Number):CompositeSeekOperationInfo
		{
			var serialSegments:Vector.<SerialElementSegment> = prepareSerialSegments();

			var seekToOp:SerialSeekOperationInfo;
			var curChildIndex:int = traitAggregator.getChildIndex(traitAggregator.listenedChild);
			if (curChildIndex < serialSegments.length)
			{
				var curChildSeekOperation:SerialElementSegment = serialSegments[curChildIndex];
				
				// Check whether this is a seek within the current child
				if (curChildSeekOperation.relativeStart <= time && time <= curChildSeekOperation.relativeEnd)
				{
					seekToOp = new SerialSeekOperationInfo();
					seekToOp.canSeekTo = true;
					seekToOp.fromChild = curChildSeekOperation.mediaElement;
					seekToOp.toChild = curChildSeekOperation.mediaElement;
					
					// Convert from the composite playhead position to child playhead position
					seekToOp.toChildTime = time - curChildSeekOperation.relativeStart;
				}
				else if (time < curChildSeekOperation.relativeStart)
				{
					seekToOp = canSeekBackward(time, serialSegments, curChildIndex);
				}
				else
				{
					seekToOp = canSeekForward(time, serialSegments, curChildIndex);
				}
			}
			else
			{
				// Seeking is not possible within the current child.
				seekToOp = new SerialSeekOperationInfo();
				seekToOp.canSeekTo = false;
			}

			return seekToOp;
		}
		
		/**
		 * @private
		 */
		override protected function checkSeeking():Boolean
		{
			// Serail composite seekable is only in seeking state when the current child is in
			// seeking state.
			return (traitOfCurrentChild != null) ? traitOfCurrentChild.seeking : false;
		}

		// Internals
		//

		private function prepareSerialSegments():Vector.<SerialElementSegment>
		{
			var serialSegments:Vector.<SerialElementSegment> = new Vector.<SerialElementSegment>();
			
			var currentTime:Number = 0;
			
			for (var i:int = 0; i < traitAggregator.numChildren; i++)
			{
				var mediaElement:MediaElement = traitAggregator.getChildAt(i);
				
				var timeTrait:TimeTrait = mediaElement.getTrait(MediaTraitType.TIME) as TimeTrait;
				
				// If a child has no duration, it will be skipped.
				if (timeTrait != null && !isNaN(timeTrait.duration))
				{
					serialSegments.push
						( new SerialElementSegment
							( mediaElement
							, currentTime
							, currentTime + timeTrait.duration
							, mediaElement.hasTrait(MediaTraitType.SEEK) == false
							)
						);
	
					currentTime += timeTrait.duration;
				}
				else
				{
					// Push an empty segment so that we maintain one segment
					// for each child.
					serialSegments.push
						( new SerialElementSegment
							( mediaElement
							, currentTime
							, currentTime
							, mediaElement.hasTrait(MediaTraitType.SEEK) == false
							)
						);
				}
			}
			
			return serialSegments;
		}

		override protected function onSeekingChanged(event:SeekEvent):void
		{
			// If the composite is in the middle of a seek that crosses multiple children,
			// the composite trait will expect to receive SeekingChangeEvents from its children.
			// Once all children finish seeking, then the seek is considered complete.
			if (crossChildrenSeeking)
			{
				// When executing a cross-child seek, we must wait until all of the seeks
				// are initiated before checking to see if we should signal that the entire
				// seek is complete, or else we'll end up with a false positive.
				if (allCrossChildrenSeeksInitiated)
				{
					var child:MediaElement;
					while (child = traitAggregator.getNextChildWithTrait(child, MediaTraitType.SEEK))
					{					
						if ((child.getTrait(MediaTraitType.SEEK) as SeekTrait).seeking)
						{
							return; //return if any children haven't completed the seek.
						}
					}
					crossChildrenSeeking = false;
					
					if (readyToExitSeekingState)
					{
						// The child is exiting the seeking state, so we just
						// update the composite seeking state.
						setSeeking(false, timeTrait != null ? timeTrait.currentTime : 0);
					}
					else
					{
						// Save the time which we'll pass to the setSeeking method.
						exitSeekingStateTime = timeTrait != null ? timeTrait.currentTime : 0;
					}		
				}
			}					
			else
			{
				var newSeekingState:Boolean = checkSeeking();
				if (newSeekingState != seeking)
				{
					// At this point, we know that the change of the child seeking state will cause the
					// composite seeking state to change.
					if (newSeekingState)
					{
						// Do nothing.
					}
					else
					{
						
						// The child is exiting the seeking state, so we just
						// update the composite seeking state.
						setSeeking(false, event.time);
					}
				}
			}
		}

		private function canSeekBackward
			( time:Number
			, serialSegments:Vector.<SerialElementSegment>
			, curChildIndex:int):SerialSeekOperationInfo
		{
			var seekToOp:SerialSeekOperationInfo = new SerialSeekOperationInfo();
			seekToOp.seekForward = false;
			seekToOp.canSeekTo = false;
			
			// If the current child is the first child of the serial element, and the
			// composite trait still needs to seek to the left of the current child,
			// it is definitely unseekable.
			var index:int = curChildIndex - 1;
			if (index < 0)
			{
				return seekToOp;
			}

			seekToOp.fromChild = serialSegments[curChildIndex].mediaElement;
					
			var curSegment:SerialElementSegment = serialSegments[index];
			while (curSegment != null)
			{
				var childSeekTrait:SeekTrait = curSegment.mediaElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
				if (time >= curSegment.relativeStart)
				{
					if (childSeekTrait == null)
					{
						curSegment = serialSegments[index+1];
						seekToOp.toChild = curSegment.mediaElement;
						seekToOp.toChildTime = 0;
					}
					else
					{
						seekToOp.toChild = curSegment.mediaElement;
						seekToOp.toChildTime = time - curSegment.relativeStart;
					}
					
					seekToOp.canSeekTo = true;
					break;
				}
				
				index--;
				if (index < 0)
				{
					break;
				}	
				else
				{
					seekToOp.inBetweenChildren.push(curSegment);
					
					curSegment = serialSegments[index];
				}
			}
			
			return seekToOp;
		}

		private function canSeekForward
			( time:Number
			, serialSegments:Vector.<SerialElementSegment>
			, curChildIndex:int):SerialSeekOperationInfo
		{
			var seekToOp:SerialSeekOperationInfo = new SerialSeekOperationInfo();
			seekToOp.seekForward = true;
			seekToOp.canSeekTo = false;

			// If the current child is the last child of the serial element, and the
			// composite trait still needs to seek to the right of the current child,
			// it is definitely unseekable.
			var index:int = curChildIndex + 1;
			if (index >= serialSegments.length)
			{
				return seekToOp;
			}

			seekToOp.fromChild = serialSegments[curChildIndex].mediaElement;

			var curSegment:SerialElementSegment = serialSegments[index];
			while (curSegment != null)
			{
				if (time <= curSegment.relativeEnd)
				{
					var childSeekTrait:SeekTrait = curSegment.mediaElement.getTrait(MediaTraitType.SEEK) as SeekTrait;
					if (childSeekTrait == null)
					{
						// Not seekable.
						break;
					}
					else
					{
						seekToOp.toChild = curSegment.mediaElement;
						seekToOp.toChildTime = time - curSegment.relativeStart;
					}
					
					seekToOp.canSeekTo = true;
					break;
				}
				
				index++;
				if (index >= serialSegments.length || curSegment.unseekable)
				{
					// Not seekable.
					break;
				}	
				else
				{
					seekToOp.inBetweenChildren.push(curSegment);
					
					curSegment = serialSegments[index];
				}
			}
			
			return seekToOp;
		}
		
		private function get traitOfCurrentChild():SeekTrait
		{
			return   traitAggregator.listenedChild
				   ? traitAggregator.listenedChild.getTrait(MediaTraitType.SEEK) as SeekTrait
				   : null;			
		}
		
		private function getCompositePlayState():String
		{
			var playTrait:PlayTrait = owner.getTrait(MediaTraitType.PLAY) as PlayTrait;
			return (playTrait == null) ? null : playTrait.playState;
		}
		
		private var owner:MediaElement;
		private var crossChildrenSeeking:Boolean;
		private var allCrossChildrenSeeksInitiated:Boolean;
		private var readyToExitSeekingState:Boolean = true;
		private var exitSeekingStateTime:Number;
	}
}