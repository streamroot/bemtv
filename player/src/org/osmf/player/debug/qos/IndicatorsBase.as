/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package org.osmf.player.debug.qos
{
	import flash.utils.Dictionary;
	
	import org.osmf.player.chrome.configuration.ConfigurationUtils;

	/**
	 * Base class for StrobeMediaPlayer indicators. 
	 * 
	 * Currently is responsible for assembling the list of public properties. 
	 */ 
	public class IndicatorsBase
	{
		public function getFields():Array
		{
			var result:Array = getOrderedFieldList();	
			var filter:Array = getFilterFieldList();
			var fields:Dictionary = ConfigurationUtils.retrieveFields(this, false);			
			var nonOrderedFields:Array = new Array();
			for (var fieldName:String in fields)
			{
				if (filter.indexOf(fieldName) <0 && result.indexOf(fieldName) < 0)
				{
					nonOrderedFields.push(fieldName);
				}
			}
			nonOrderedFields.sort();
			result = result.concat(nonOrderedFields);
			return result;
		}
		
		protected function getOrderedFieldList():Array
		{
			return [];
		}
		
		protected function getFilterFieldList():Array
		{
			return [];
		}
	}
}