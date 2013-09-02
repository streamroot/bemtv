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
package org.osmf.metadata
{
	import org.osmf.elements.compositeClasses.CompositionMode;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Defines an algorithm that can synthesize a metadata value
	 * from any number of metadata values of a given namespace, in
	 * the context of a target parent Metadata, child Metadatas,
	 * CompositionMode, and active child Metadata context (for
	 * SerialElements).
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class MetadataSynthesizer
	{
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function MetadataSynthesizer()
		{
		}
				
		/**
		 * Synthesizes a metadata value from the passed arguments.
		 * 
		 * If the specified mode is SERIAL, then the active metadata of the synthesizer's
		 * type will be returned as the synthesized metadata.
		 * 
		 * If the specified mode is PARALLEL, then the synthesized metadata value will be null,
		 * unless the metadata group contains a single child, in which case the single child is
		 * what is return as the synthesized metadata.
		 * 
		 * @param namespaceURL The namespace URL to synthesize values for.
		 * @param targetParentMetadata The parent metadata that will have the synthesized
		 * value appended.
		 * @param metadatas The metadata objects the synthesized value should be based
		 * on.
		 * @param mode The CompositionMode of synthesis that should be applied.
		 * @param serialElementActiveChildMetadata If the targetParentMetadata value belongs to a
		 * SerialElement this value references the metadata of its currently active child.
		 * @return The synthesized value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function synthesize
							( namespaceURL:String
							, targetParentMetadata:Metadata
							, metadatas:Vector.<Metadata>
							, mode:String
							, serialElementActiveChildMetadata:Metadata
							):Metadata
		{	
			var result:Metadata;
			
			if (mode == CompositionMode.SERIAL && serialElementActiveChildMetadata)
			{
				// Return the currently active metadata:
				result = serialElementActiveChildMetadata.getValue(namespaceURL) as Metadata;
			}
			else // mode is PARALLEL
			{
				// Return the first metadata as the synthesized metadata:
				result
					= (metadatas.length >= 1)
						? metadatas[0]
						: null;
			}
			
			return result;
		}
	}
}