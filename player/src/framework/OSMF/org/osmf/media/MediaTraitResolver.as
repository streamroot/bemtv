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
package org.osmf.media
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;
	
	[ExcludeClass]
	
	/**
	 * Dispatched when the resolver's resolvedTrait property changed.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * @private
	 * 
	 * Abstract base class for objects that keep a list of traits of similar type, capable
	 * of pointing out a so called "active" trait, that currently represents the group.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	internal class MediaTraitResolver extends EventDispatcher
	{
		/**
		 * Constructor
		 *  
		 * @param type The MediaTraitType for traits that this resolver will be resolving.
		 * @throws ArgumentError If type is null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MediaTraitResolver(type:String)
		{
			if (type == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			_type = type;
		}
		
		/**
		 * Defines the MediaTraitType that the resolver handles.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function get type():String
		{
			return _type;
		}
		
		/**
		 * Method for use by subclasses to set the resolved trait. Triggers
		 * a change event if the set value differs from the current value.
		 * 
		 * @param value The trait instance to set as the resolved trait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		final protected function setResolvedTrait(value:MediaTraitBase):void
		{
			if (value != _resolvedTrait)
			{
				if (_resolvedTrait)
				{ 
					_resolvedTrait = null;
					dispatchEvent(new Event(Event.CHANGE));
				}
				
				_resolvedTrait = value;
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		/**
		 * Defines the trait instance that currently represents the group of traits as
		 * a whole.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function get resolvedTrait():MediaTraitBase
		{
			return _resolvedTrait;	
		}
		
		/**
		 * Adds a trait instance to the resolver. Whether the specified instance gets
		 * added is at the discretion of the implementing resolver.
		 * 
		 * Invokes processAddTrait, that subclasses are expected to override.
		 * 
		 * @param instance The instance to add.
		 * @throws ArgumentError If the passed trait is null, or if the trait's type
		 * does not match the resolver's trait type.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		final public function addTrait(instance:MediaTraitBase):void
		{	
			if (instance == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			if (instance.traitType != type)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			processAddTrait(instance);
		}
		 
		 /**
		 * Removes a trait instance from the resolver. Whether the specified instance gets
		 * removed is at the discretion of the implementing resolver.
		 * 
		 * Invokes processRemoveTrait, that subclasses are expected to override.
		 * 
		 * @param instance The instance to remove.
		 * @return The instance that was removed. Null if no matching instance was found.
		 * @throws ArgumentError If the passed trait is null, or if the trait's type
		 * does not match the resolver's trait type.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final public function removeTrait(instance:MediaTraitBase):MediaTraitBase
		{
			if (instance == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			if (instance.traitType != type)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return processRemoveTrait(instance);
		}
		
		// Subclass stubs
		//
		
		/**
		 * Stub method that is invoked from addTrait. Subclasses should place their
		 * instance adding logic in an override to this method.
		 * 
		 * @param instance The trait instance to add. On invocation of this method,
		 * instance has been checked for not being null, or of the wrong trait type.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function processAddTrait(instance:MediaTraitBase):void
		{	
		}
		
		/**
		 * Stub method that is invoked from removeTrait. Subclasses should place their
		 * instance removing logic in an override to this method.
		 * 
		 * @param instance The trait instance to add. On invocation of this method,
		 * instance has been checked for not being null, or of the wrong trait type.
		 * @return The instance that got removed, or null if no instance got removed. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function processRemoveTrait(instance:MediaTraitBase):MediaTraitBase
		{
			return null;
		}
		
		private var _type:String;
		private var _resolvedTrait:MediaTraitBase;
	}
}