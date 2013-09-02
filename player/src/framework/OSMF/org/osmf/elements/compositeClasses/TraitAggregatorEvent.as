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
	import org.osmf.traits.MediaTraitBase;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The TraitAggregator dispatches a TraitAggregatorEvent when media traits are
	 * aggregated or unaggregated by the aggregator. 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class TraitAggregatorEvent extends Event
	{
		/**
		 * The TraitAggregatorEvent.TRAIT_AGGREGATED constant defines the value of the type
		 * property of the event object for a traitAdd event.
		 * 
		 * @eventType traitAdd
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const TRAIT_AGGREGATED:String = "traitAggregated";
		
		/**
		 * The TraitAggregatorEvent.TRAIT_UNAGGREGATED constant defines the value of the
		 * type property of the event object for a traitRemove event.
		 * 
		 * @eventType traitRemove
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const TRAIT_UNAGGREGATED:String = "traitUnaggregated";

		/**
		 * The TraitAggregatorEvent.LISTENED_CHILD_CHANGE constant defines the
		 * value of the type property of the event object for a
		 * listenedChildChange event.
		 * 
		 * @eventType traitRemove
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const LISTENED_CHILD_CHANGE:String = "listenedChildChange";
		
		/**
		 * Constructor.
		 * 
		 * @param type The event type; indicates the action that triggered the
		 * event.
		 * @param traitType The MediaTraitType for this event.
		 * @param trait The trait for this event.  Should be null for events
		 * related to the listenedChild.
		 * @param child The child for this event.  Should be null for events
		 * related to the listenedChild.
		 * @param oldListenedChild The previous value of listenedChild for the
		 * TraitAggregator.  Should be null for events related to aggregation.
		 * @param newListenedChild The new value of listenedChild for the
		 * TraitAggregator.  Should be null for events related to aggregation.
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
		public function TraitAggregatorEvent
			( type:String
			, traitType:String
			, trait:MediaTraitBase
			, child:MediaElement
			, oldListenedChild:MediaElement=null
			, newListenedChild:MediaElement=null
			, bubbles:Boolean=false
			, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);

			_child = child;
			_oldListenedChild = oldListenedChild;
			_newListenedChild = newListenedChild;
			
			_traitType = traitType;
			_trait = trait;
		}
		
		/**
		 * @private
		 */
		override public function clone():Event
		{
			return new TraitAggregatorEvent(type, _traitType, _trait, _oldListenedChild, _newListenedChild);
		}
		
		/**
		 * The MediaTraitType for this event.  Should be null for events related
		 * to the listenedChild.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get traitType():String
		{
			return _traitType;
		}
		
		/**
		 * The trait for this event.  Should be null for events related to
		 * the listenedChild.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get trait():MediaTraitBase
		{
			return _trait;
		}
		
		/**
		 * The child for this event.  Should be null for events related to
		 * the listenedChild.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get child():MediaElement
		{
			return _child;
		}
		
		/**
		 * The old value of listenedChild for the TraitAggregator.  Should be
		 * null for events related to aggregation.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get oldListenedChild():MediaElement
		{
			return _oldListenedChild;
		}

		/**
		 * The new value of listenedChild for the TraitAggregator.  Should be
		 * null for events related to aggregation.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get newListenedChild():MediaElement
		{
			return _newListenedChild;
		}
		
		// Internals
		//
		
		private var _traitType:String;
		private var _trait:MediaTraitBase;
		private var _child:MediaElement;
		private var _oldListenedChild:MediaElement;
		private var _newListenedChild:MediaElement;
	}
}