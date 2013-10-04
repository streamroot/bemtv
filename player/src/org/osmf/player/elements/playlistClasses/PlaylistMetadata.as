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

package org.osmf.player.elements.playlistClasses
{
	import flash.errors.IllegalOperationError;
	
	import org.osmf.media.MediaElement;
	import org.osmf.metadata.Metadata;
	
	/**
	 * Defines the metadata as used by PlaylistMediaElement et al.
	 * 
	 * On 'currentElement' being set, the object infers the next and previous items. UI
	 * controls can use this information to determine if previous/next buttons should
	 * be enabled.
	 */	
	public class PlaylistMetadata extends Metadata
	{
		/* static */
		public static const NAMESPACE:String = "http://www.osmf.org.player/1.0/playlist";
		public static const NEXT_ELEMENT:String = "nextElement";
		public static const PREVIOUS_ELEMENT:String = "previousElement";
		public static const GOTO_NEXT:String = "gotoNext";
		public static const GOTO_PREVIOUS:String = "gotoPrevious";
		public static const SWITCHING:String = "switching";
		
		public function PlaylistMetadata()
		{
			super();
			
			elements = new Vector.<MediaElement>();
			
			addValue(GOTO_NEXT, null);
			addValue(GOTO_PREVIOUS, null);
			addValue(SWITCHING, false);
		}
		
		public function set currentElement(value:MediaElement):void
		{
			if (value != _currentElement)
			{
				_currentElement = value;
				updatePreviousAndNextValues();
			}
		}
		
		public function get switching():Boolean
		{
			return getValue(SWITCHING);;			
		}
		
		public function set switching(value:Boolean):void
		{
			addValue(SWITCHING, value);			
		}
		
		public function get currentElement():MediaElement
		{
			return _currentElement;
		}
		
		public function get previousElement():MediaElement
		{
			return getValue(PREVIOUS_ELEMENT);
		}
		
		public function get nextElement():MediaElement
		{
			return getValue(NEXT_ELEMENT);
		}
		
		public function addElement(value:MediaElement):void
		{
			elements.push(value);	
		}
		
		public function updateElementAt(index:Number, newValue:MediaElement):void
		{
			elements[index] = newValue;
			updatePreviousAndNextValues();
		}
		
		public function get numElements():Number
		{
			return elements.length;
		}
		
		public function elementAt(index:Number):MediaElement
		{
			if (index >= 0 && elements.length > index)
			{
				return elements[index];
			}
			else
			{
				throw new IllegalOperationError();
			}
		}
		
		public function indexOf(element:MediaElement):Number
		{
			return elements.indexOf(element);
		}
		
		// Internals
		//
		
		private var elements:Vector.<MediaElement>;
		private var	_currentElement:MediaElement;
		
		private function updatePreviousAndNextValues():void
		{
			var previousElement:MediaElement;
			var nextElement:MediaElement;
			var currentElementIndex:Number = elements.indexOf(_currentElement);
			
			if (currentElementIndex != -1 && elements.length > 1)
			{
				nextElement
					= ((currentElementIndex + 1) < elements.length)
						? elements[currentElementIndex + 1]
						: null;
					
				previousElement
					= ((currentElementIndex -1 ) >= 0)
						? elements[currentElementIndex - 1]
						: null;
			}
			
			if (previousElement != this.previousElement)
			{
				addValue(PREVIOUS_ELEMENT, previousElement);
			}
			
			if (nextElement != this.nextElement)
			{
				addValue(NEXT_ELEMENT, nextElement);
			}
		}
	}
}