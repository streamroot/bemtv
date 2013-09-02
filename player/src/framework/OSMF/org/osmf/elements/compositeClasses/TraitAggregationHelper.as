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
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	internal class TraitAggregationHelper
	{
		public function TraitAggregationHelper
			( traitType:String
			, traitAggregator:TraitAggregator
			, traitAggregationFunction:Function
			, traitUnaggregationFunction:Function
			)
		{
			this.traitType = traitType;
			this.traitAggregator = traitAggregator;
			this.traitAggregationFunction = traitAggregationFunction;
			this.traitUnaggregationFunction = traitUnaggregationFunction;
			
			attach();
		}
		
		public function attach():void
		{
			// Keep apprised of traits of our type that come and go.
			traitAggregator.addEventListener(TraitAggregatorEvent.TRAIT_AGGREGATED, 	onChildAggregated, 		false, 0, true);
			traitAggregator.addEventListener(TraitAggregatorEvent.TRAIT_UNAGGREGATED, 	onChildUnaggregated, 	false, 0, true);
			
			// Process each aggregated trait of our type.
			traitAggregator.forEachChildTrait
				(	traitAggregationFunction
				,   traitType
				);
		}
		
		public function detach():void
		{
			traitAggregator.removeEventListener(TraitAggregatorEvent.TRAIT_AGGREGATED, 		onChildAggregated);
			traitAggregator.removeEventListener(TraitAggregatorEvent.TRAIT_UNAGGREGATED,	onChildUnaggregated);
		}
		
		private function onChildAggregated(event:TraitAggregatorEvent):void
		{
			if (event.traitType == traitType)
			{
				traitAggregationFunction.length == 2
					? traitAggregationFunction.call(null, event.trait, event.child)
					: traitAggregationFunction.call(null, event.trait);
			}
		}

		private function onChildUnaggregated(event:TraitAggregatorEvent):void
		{
			if (event.traitType == traitType)
			{
				traitUnaggregationFunction.length == 2
					? traitUnaggregationFunction.call(null, event.trait, event.child)
					: traitUnaggregationFunction.call(null, event.trait);
			}
		}
		
		private var traitType:String;
		private var traitAggregator:TraitAggregator;
		private var traitAggregationFunction:Function;
		private var traitUnaggregationFunction:Function;
	}
}