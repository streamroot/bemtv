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
	import flash.errors.IllegalOperationError;
	
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	import org.osmf.utils.OSMFStrings;

	/**
	 * Implementation of SeekTrait which can be a composite media trait.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class CompositeSeekTrait extends SeekTrait implements IReusable
	{
		public function CompositeSeekTrait(traitAggregator:TraitAggregator, mode:String, owner:MediaElement)
		{
			super(owner.getTrait(MediaTraitType.TIME) as TimeTrait);
			
			// Add listener for traitAdd/remove, in case TimeTrait changes (or
			// doesn't exist yet).
			owner.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
			owner.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
			
			_traitAggregator = traitAggregator;
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
		override protected function seekingChangeEnd(time:Number):void
		{
			super.seekingChangeEnd(time);
			
			if (seeking)
			{
				// Calls prepareSeekOperationInfo methods of the derived classes, ParallelSeekTrait
				// and SerialSeekTrait. The prepareSeekOperationInfo returns whether the composite
				// trait can seek to the position. If yes, it also returns a "description" of how
				// to carry out the seek operation for the composite, depending on the concrete type 
				// of the composite seek trait.
				var seekOp:CompositeSeekOperationInfo = prepareSeekOperationInfo(time);
				if (seekOp.canSeekTo)
				{
					doSeek(seekOp);
				}
			}
		}
		
		/**
		 * @private
		 */
		override public function canSeekTo(time:Number):Boolean
		{
			// Similar to the seek function, here we call the prepareSeekOperation of the derived
			// composite seek trait. Only this time the returned operation is only used to 
			// determine whether a seek is possible.
			return super.canSeekTo(time) && prepareSeekOperationInfo(time).canSeekTo;
		}

		// Internals
		//
		
		private function onTraitAdd(event:MediaElementEvent):void
		{
			if (event.traitType == MediaTraitType.TIME)
			{
				super.timeTrait = MediaElement(event.target).getTrait(MediaTraitType.TIME) as TimeTrait;
			}
		}

		private function onTraitRemove(event:MediaElementEvent):void
		{
			if (event.traitType == MediaTraitType.TIME)
			{
				super.timeTrait = null;
			}
		}
		
		private function processAggregatedChild(child:MediaTraitBase):void
		{
			child.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChanged, false, 0, true);
		}

		private function processUnaggregatedChild(child:MediaTraitBase):void
		{
			child.removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChanged);
		}
		
		/**
		 * This is event handler for SeekEvent, typically dispatched from the SeekTrait
		 * of a child/children. This must be overridden by derived classes. 
		 * 
		 * @param event The SeekEvent.
  		 *  
  		 *  @langversion 3.0
  		 *  @playerversion Flash 10
  		 *  @playerversion AIR 1.5
  		 *  @productversion OSMF 1.0
  		 */
		protected function onSeekingChanged(event:SeekEvent):void
		{
			throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.FUNCTION_MUST_BE_OVERRIDDEN));
		}
		
		/**
		 * This function carries out the actual seeking operation. Derived classes must override this
		 * function. 
		 * 
		 * @param seekOp The object that contains the complete information of how to carry out this 
		 * particular seek operation.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function doSeek(seekOp:CompositeSeekOperationInfo):void
		{
			throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.FUNCTION_MUST_BE_OVERRIDDEN));
		}
		
		/**
		 * This function carries out the operation to check whether a seek operation is feasible
		 * as well as coming up with a complete plan of how to do the actual seek. The derived 
		 * classes must override this function.
		 * 
		 * @param time The time the seek operation will seek to.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function prepareSeekOperationInfo(time:Number):CompositeSeekOperationInfo
		{
			throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.FUNCTION_MUST_BE_OVERRIDDEN));
		}
		
		/**
		 * This function checks whether the composite seek trait is currently seeking.  The derived
		 * classes must override this function.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function checkSeeking():Boolean
		{
			throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.FUNCTION_MUST_BE_OVERRIDDEN));
		}
		
		protected final function get traitAggregator():TraitAggregator
		{
			return _traitAggregator;
		}

		// Internals
		//
		
		private var mode:String;
		private var _traitAggregator:TraitAggregator;
		private var traitAggregationHelper:TraitAggregationHelper;
	}
}
