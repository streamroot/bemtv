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
package org.osmf.layout
{
	import __AS3__.vec.Vector;
	
	import org.osmf.utils.OSMFStrings;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Utility class that generalizes binary search within sorted lists.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class BinarySearch
	{
		/**
		 * Method for searching an item in a sorted list.
		 *  
		 * @param list The vector to search.
		 * @param compare The method used to compare item with items in collection:
		 * function(item:*, listItem:*):int. Expected to return:
		 * -1 when item &lt; listItem,
		 * 0 when item == listItem, and
		 * 1 when item &gt; listItem.
		 * @param item The item to search for.
		 * @param firstIndex The left hand-side bound to limit the search to.
		 * @param lastIndex The right hand-side bound to limit the search to.
		 * @return The index of the item searched for. If no match is found, returns
		 * the index (1 based) where the item should be inserted as a negative number.
		 * @throws ArgumentError If compare or list is <code>null</code>.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public static function search(list:Object, compare:Function, item: *, firstIndex:int = 0, lastIndex:int = int.MIN_VALUE):int
		{
			if 	(	list == null
				||	compare == null
				)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			var result:int = -firstIndex;
			
			lastIndex 
				= lastIndex == int.MIN_VALUE
					? list.length - 1
					: lastIndex;
			
			if	(	list.length > 0
				&&	firstIndex <= lastIndex
				)
			{
				var middle:int = (firstIndex + lastIndex) / 2;
				var listItem:* = list[middle];
				
				switch (compare(item, listItem))
				{
					case -1	:
						result = search(list, compare, item, firstIndex, middle - 1);
						break;
					case 0	:
						result = middle;
						break;
					case 1	:
						result = search(list, compare, item, middle + 1, lastIndex);
						break;
				}
			}
			
			return result;
		}
		
	}
}