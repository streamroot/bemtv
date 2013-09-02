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
	CONFIG::LOGGING 
	{	
		import org.osmf.logging.Logger;
	}
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.utils.OSMFStrings;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Defines a trait resolver that tracks two traits: a default trait
	 * the is set at consturction time, plus one additional trait that
	 * can be set via the addTrait method.
	 * 
	 * For as long as the second trait has not been added, the resolver's
	 * resolved trait will point to the default trait. This changes once
	 * another trait has been added via addTrait: at that point, the
	 * added trait is what the resolver will resolve to.
	 * 
	 * Removing the added trait will re-instate the default trait as the
	 * resolvee.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class DefaultTraitResolver extends MediaTraitResolver
	{
		/**
		 * Constructor.
		 * 
		 * @param type The MediaTraitType for the trait to resolve.
		 * @param defaultTrait The default trait to resolve to for as long
		 * as no other trait has been added to the resolver.
		 * 
		 * @throws ArgumentError If defaultTrait is null, or if its type does
		 * not match the specified type.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function DefaultTraitResolver(type:String, defaultTrait:MediaTraitBase)
		{
			super(type);
			
			if (defaultTrait == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			if (defaultTrait.traitType != type)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			this.defaultTrait = defaultTrait;
			setResolvedTrait(defaultTrait);
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 * 
		 * Only a single trait can be added to this resolver. Attempting to
		 * add a second will fail. To change the trait, remove the previously
		 * added one first.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		override protected function processAddTrait(instance:MediaTraitBase):void
		{
			if (trait == null)
			{
				setResolvedTrait(trait = instance);
			}
			else
			{
				CONFIG::LOGGING
				{
					logger.warn("Trait addition ignored by resolver: a non default trait had already been set.");
				}
			}
		}
		
		/**
		 * @private
		 */		
		override protected function processRemoveTrait(instance:MediaTraitBase):MediaTraitBase 
		{
			var result:MediaTraitBase;
			
			if (instance && instance == trait)
			{
				result = trait;
				trait = null;
				
				setResolvedTrait(defaultTrait);
			}
			
			return result;
		}
		
		// Internals
		//
		
		private var defaultTrait:MediaTraitBase;
		private var trait:MediaTraitBase;
		
		CONFIG::LOGGING private static const logger:org.osmf.logging.Logger = org.osmf.logging.Log.getLogger("org.osmf.media.DefaultTraitResolver");
	}
}