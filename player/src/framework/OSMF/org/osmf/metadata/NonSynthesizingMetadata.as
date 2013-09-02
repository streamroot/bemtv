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
package org.osmf.metadata
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Defines a Metadata class that has a NullMetadataSynthesizer.
	 * 
	 * NonSynthesizingMetadata objects are local to the metadata that they
	 * get added to. When this metadata object becomes part of a composition,
	 * the owning media element will not be reflecting it.
	 */	
	public class NonSynthesizingMetadata extends Metadata
	{
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 		
		public function NonSynthesizingMetadata()
		{
			_synthesizer = new NullMetadataSynthesizer();
			
			super();
		}
		
		// Overrides
		//
		
		/**
		 * @private
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function get synthesizer():MetadataSynthesizer
		{
			return _synthesizer;
		}
		
		// Internals
		//
		
		private var _synthesizer:MetadataSynthesizer;
	}
}