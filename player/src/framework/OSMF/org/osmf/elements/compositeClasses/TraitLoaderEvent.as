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
	import flash.events.Event;
	
	import org.osmf.media.MediaElement;
	
	/**
	 * The TraitLoader dispatches a TraitLoaderEvent when the requested
	 * MediaElement has been found.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class TraitLoaderEvent extends Event
	{
		/**
		 * The TraitLoaderEvent.TRAIT_FOUND constant defines the value of the type
		 * property of the event object for a traitFound event.
		 * 
		 * @eventType traitAdd
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const TRAIT_FOUND:String = "traitFound";
				
		/**
		 * Constructor.
		 * 
		 * @param mediaElement The found MediaElement.  May be null if no such
		 * element found.
 		 * @param bubbles Specifies whether the event can bubble up the display
 		 * list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the
 		 * event can be prevented. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function TraitLoaderEvent
			( mediaElement:MediaElement=null
			, bubbles:Boolean=false
			, cancelable:Boolean=false)
		{
			super(TRAIT_FOUND, bubbles, cancelable);

			this.mediaElement = mediaElement;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new TraitLoaderEvent(mediaElement);
		}
		
		/**
		 * The found MediaElement.  May be null if no such element found.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public var mediaElement:MediaElement;
	}
}