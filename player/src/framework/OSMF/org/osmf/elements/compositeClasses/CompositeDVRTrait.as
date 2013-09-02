/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
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
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/

package org.osmf.elements.compositeClasses
{
	import org.osmf.events.DVREvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;

	[ExcludeClass]
	
	/**
	 * @private
	 */
	internal class CompositeDVRTrait extends DVRTrait implements IReusable
	{
		/**
	 	 * @private
	 	 */
		public function CompositeDVRTrait(traitAggregator:TraitAggregator, owner:MediaElement, mode:String) 
		{
			this.traitAggregator = traitAggregator;
			this.mode = mode;
			
			super();
			
			traitAggregationHelper
				= new TraitAggregationHelper
					( traitType
					, traitAggregator
					, processAggregatedChild
					, processUnaggregatedChild
					);
		}
	
		// IReusable
		//
		
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
		
		// Internals
		//
		
		private function processAggregatedChild(childTrait:MediaTraitBase, child:MediaElement):void
		{
			childTrait.addEventListener(DVREvent.IS_RECORDING_CHANGE, onChildIsRecordingChange);
			onChildIsRecordingChange();
		}
		
		private function processUnaggregatedChild(childTrait:MediaTraitBase, child:MediaElement):void
		{
			childTrait.removeEventListener(DVREvent.IS_RECORDING_CHANGE, onChildIsRecordingChange);
			onChildIsRecordingChange();
		}
		
		private function onChildIsRecordingChange(event:DVREvent = null):void
		{
			if (mode == CompositionMode.SERIAL)
			{
				// isRecording must be true if the active child's isRecording
				// property is true:
				var dvrTrait:DVRTrait
					= traitAggregator.listenedChild
						? traitAggregator.listenedChild.getTrait(MediaTraitType.DVR) as DVRTrait
						: null;
						
				if (dvrTrait)
				{
					// Update the composite's isRecording property to match the
					// curent child's one:
					setIsRecording(dvrTrait.isRecording);
				}
			}
			else // PARALLEL
			{
				// isRecording must be true if at least one of the children
				// is recording:				
				var newIsRecording:Boolean;
				traitAggregator.forEachChildTrait
					( function(dvrTrait:DVRTrait):void
						{
							newIsRecording ||= dvrTrait.isRecording;	
						}
					, MediaTraitType.DVR
					);
					
				if (isRecording != newIsRecording)
				{
					setIsRecording(newIsRecording);
				}
			}
		}
		
		private var mode:String;
		private var traitAggregator:TraitAggregator;
		
		private var traitAggregationHelper:TraitAggregationHelper;
	}
}