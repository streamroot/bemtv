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
	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaError;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.DRMState;
	import org.osmf.traits.DRMTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;

	/**
	 * @private
	 */
	internal class CompositeDRMTrait extends DRMTrait implements IReusable
	{
		/**
		 * @private 
		 */ 
		public function CompositeDRMTrait(traitAggregator:TraitAggregator, owner:MediaElement, mode:String)
		{
			super();
			
			if (drmLevels == null)
			{
				drmLevels = {};				
				drmLevels[DRMState.DRM_SYSTEM_UPDATING] = 0;
				drmLevels[DRMState.AUTHENTICATION_ERROR] = 1;
				drmLevels[DRMState.AUTHENTICATION_NEEDED] = 2;
				drmLevels[DRMState.UNINITIALIZED]  = 3;
				drmLevels[DRMState.AUTHENTICATING] = 4;
				drmLevels[DRMState.AUTHENTICATION_COMPLETE] = 5;			
				drmLevels[""] = 6;	 //Unknown is considered the highest state, giving it the least weight						
			}	
						
			this.mode = mode;
			this.traitAggregator = traitAggregator;
			this.owner = owner;
			traitAggregationHelper = new TraitAggregationHelper
				( traitType
				, traitAggregator
				, processAggregatedChild
				, processUnaggregatedChild
				);		
			if (mode == CompositionMode.SERIAL)
			{
				traitAggregator.addEventListener(TraitAggregatorEvent.LISTENED_CHILD_CHANGE, listenedChildChange);		
			}
						
		}		
		
		/**
		 * @private
		 */
		public function attach():void
		{
			if (traitAggregationHelper)
			{
				traitAggregationHelper.attach();
			}
		}
		
		/**
		 * @private
		 */
		public function detach():void
		{
			if (traitAggregationHelper)
			{
				traitAggregationHelper.detach();
			}
		}
		
		/**
		 * @private 
		 */ 
		override public function get endDate():Date
		{
			var end:Date = null;
			if (mode == CompositionMode.SERIAL)
			{
				var listenedTrait:DRMTrait = traitAggregator.listenedChild ? traitAggregator.listenedChild.getTrait(MediaTraitType.DRM) as DRMTrait : null;
				end = listenedTrait ? listenedTrait.endDate : null;		
			}
			else //Parallel
			{				
				traitAggregator.forEachChildTrait(
				function(trait:DRMTrait):void
				{
					if (end && trait.endDate)
					{
						end = end.time < trait.endDate.time ? end : trait.endDate;	
					}
					else if (end == null &&
							 trait.endDate != null)
					{
						end = trait.endDate;		
					}					
				},MediaTraitType.DRM);
			}
			
			return end;			
		}
		
		/**
		 * @private 
		 */ 
		override public function get startDate():Date
		{
			var start:Date = null;
			if (mode == CompositionMode.SERIAL)
			{
				var listenedTrait:DRMTrait = traitAggregator.listenedChild ? traitAggregator.listenedChild.getTrait(MediaTraitType.DRM) as DRMTrait : null;
				start = listenedTrait ? listenedTrait.startDate : null;		
			}
			else //Parallel
			{				
				traitAggregator.forEachChildTrait(
				function(trait:DRMTrait):void
				{
					if (start && trait.startDate)
					{
						start = start.time > trait.startDate.time ? start : trait.startDate;	
					}
					else if (start == null &&
							 trait.startDate != null)
					{
						start = trait.startDate;		
					}		
				},MediaTraitType.DRM);
			}
			
			return start;
		}
		
		/**
		 * @private 
		 */ 
		override public function get period():Number
		{
			var newPeriod:Number = NaN;
			if (mode == CompositionMode.SERIAL)
			{
				var listenedTrait:DRMTrait = traitAggregator.listenedChild ? traitAggregator.listenedChild.getTrait(MediaTraitType.DRM) as DRMTrait : null;
				newPeriod = listenedTrait ? listenedTrait.period : NaN;		
			}
			else //Parallel
			{					
				traitAggregator.forEachChildTrait(
				function(trait:DRMTrait):void
				{
					newPeriod = (newPeriod < trait.period) ? newPeriod : trait.period;			
				},MediaTraitType.DRM);
			}
			
			return newPeriod;
		}
	
		/**
		 * @private 
		 */ 
		override public function get drmState():String
		{
			return calculatedDrmState;			
		}
		
		/**
		 * @private 
		 */ 
		override public function authenticate(username:String=null, password:String=null):void
		{			
			invokeOnChildren("authenticate", [username, password]);
		}
		
		/**
		 * @private 
		 */ 		
		override public function authenticateWithToken(token:Object):void
		{		
			invokeOnChildren("authenticateWithToken", [token]);
		}
		
		private function invokeOnChildren(methodName:String, args:Array):void
		{
			if (mode == CompositionMode.SERIAL)
			{
				var listenedTrait:DRMTrait = traitAggregator.listenedChild ? traitAggregator.listenedChild.getTrait(MediaTraitType.DRM) as DRMTrait : null;
				if (listenedTrait != null)
				{
					(listenedTrait[methodName]).apply(listenedTrait, args);
				} 
			}
			else
			{
				var child:MediaElement = traitAggregator.getNextChildWithTrait(null, MediaTraitType.DRM);
				var drmTrait:DRMTrait;
				while (child != null)
				{		
					drmTrait = child.getTrait(MediaTraitType.DRM) as DRMTrait;							
					if (drmTrait.drmState == DRMState.AUTHENTICATION_ERROR || 
						drmTrait.drmState == DRMState.AUTHENTICATION_NEEDED)
					{
						(drmTrait[methodName]).apply(drmTrait, args);
						return;
					}
					child = traitAggregator.getNextChildWithTrait(child, MediaTraitType.DRM);
				}
			}
		}
					
		/**
		 * @private 
		 */ 		
		override public function dispose():void
		{
			if (traitAggregationHelper != null)
			{
				traitAggregationHelper.detach();
				traitAggregationHelper = null;
			}
			super.dispose();
		}
		
		/**
		 * @private 
		 */ 			
		private function recalculateDRMState():void
		{
			calculatedDrmState = "";
			if (mode == CompositionMode.SERIAL)
			{
				var listenedTrait:DRMTrait = traitAggregator.listenedChild ? traitAggregator.listenedChild.getTrait(MediaTraitType.DRM) as DRMTrait : null;
				calculatedDrmState = listenedTrait ? listenedTrait.drmState : DRMState.UNINITIALIZED;		
			}
			else //Parallel
			{			
				function nextChildTrait(trait:DRMTrait):void
				{		
					var level:Number = drmLevels[trait.drmState];
					if (level < drmLevels[calculatedDrmState])
					{
						calculatedDrmState = trait.drmState;
					}			
				}					
				traitAggregator.forEachChildTrait(nextChildTrait, MediaTraitType.DRM);
			}
		}
		
		private function processAggregatedChild(childTrait:MediaTraitBase, child:MediaElement):void
		{			
			DRMTrait(childTrait).addEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);						
			onChildDRMChange(DRMTrait(childTrait).drmState);
		}
		
		private function processUnaggregatedChild(childTrait:MediaTraitBase, child:MediaElement):void
		{			
			DRMTrait(childTrait).removeEventListener(DRMEvent.DRM_STATE_CHANGE, onDRMStateChange);	
			onChildDRMChange(calculatedDrmState);
		}
		
		private function onDRMStateChange(event:DRMEvent):void
		{			
			onChildDRMChange(event.drmState, event.token, event.mediaError, event.startDate, event.endDate, event.period, event.serverURL);
		}
		
		private function onChildDRMChange(newState:String, token:Object = null, error:MediaError = null, start:Date=null, end:Date=null, period:Number=0, serverURL:String = null):void
		{
			var oldState:String = calculatedDrmState;
			recalculateDRMState();		
			if (oldState != calculatedDrmState ||
					(calculatedDrmState == DRMState.AUTHENTICATION_NEEDED &&  //If we authenticated one piece of content, and there are still others, disptatch another auth needed.
					 newState == DRMState.AUTHENTICATION_COMPLETE))
			{					
				dispatchEvent(new DRMEvent(DRMEvent.DRM_STATE_CHANGE, drmState, false, false, startDate, endDate, period, serverURL,  token, error));
			}
		}
		
		private function listenedChildChange(event:TraitAggregatorEvent):void
		{				
			onChildDRMChange(null);			
		}
		
		private static var drmLevels:Object;
		
		private var mode:String;
		private var calculatedDrmState:String = "";
		private var traitAggregationHelper:TraitAggregationHelper
		private var owner:MediaElement;
		private var traitAggregator:TraitAggregator;
		
	}
}