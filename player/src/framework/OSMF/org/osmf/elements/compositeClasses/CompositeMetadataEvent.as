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
	
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataGroup;
	import org.osmf.metadata.MetadataSynthesizer;

	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Defines the event class that CompositeMetadata uses on signaling
	 * various events.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class CompositeMetadataEvent extends Event
	{
		public static const CHILD_ADD:String = "childAdd";
		public static const CHILD_REMOVE:String = "childRemove";
		public static const METADATA_GROUP_ADD:String = "metadataGroupAdd";
		public static const METADATA_GROUP_REMOVE:String = "metadataGroupRemove";
		public static const METADATA_GROUP_CHANGE:String = "metadataGroupChange";
		
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function CompositeMetadataEvent
							( type:String
							, bubbles:Boolean=false
							, cancelable:Boolean=false
							, child:Metadata = null
							, childMetadataNamespaceURL:String = null
							, childMetadata:Metadata = null
							, metadataGroup:MetadataGroup = null
							, suggestedMetadataSynthesizer:MetadataSynthesizer = null
							)
		{
			super(type, bubbles, cancelable);
			
			_child = child;
			_childMetadataNamespaceURL = childMetadataNamespaceURL;
			_childMetadata = childMetadata;
			_metadataGroup = metadataGroup;
			_suggestedMetadataSynthesizer = suggestedMetadataSynthesizer;
		}
		
		/**
		 * Defines the child that is associated with the event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get child():Metadata
		{
			return _child;
		}
		
		/**
		 * Defines the namespaceURL of the childMetadata associated with the event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get childMetadataNamespaceURL():String
		{
			return _childMetadataNamespaceURL;
		}

		/**
		 * Defines the metadata of the child that is associated with the event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get childMetadata():Metadata
		{
			return _childMetadata;
		}
		
		/**
		 * Defines the metadataGroup that is associated with the event.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get metadataGroup():MetadataGroup
		{
			return _metadataGroup;
		}
		
		/**
		 * @private
		 * 
		 * Method for handler functions to suggest a metadata synthesizer to
		 * the dispatching composite metadata collection instance.
		 * 
		 * @param value The suggested metadata synthesizer.
		 */		
		public function set suggestedMetadataSynthesizer(value:MetadataSynthesizer):void
		{
			_suggestedMetadataSynthesizer = value;
		}
		
		/**
		 * @private
		 * 
		 * Defines the metadataSynthesizer that is to be used for synthesis. This
		 * value can be set by listeners that wish to suggest a synthesizer. 
		 */	
		public function get suggestedMetadataSynthesizer():MetadataSynthesizer
		{
			return _suggestedMetadataSynthesizer;
		}
		
		// Overrides
		//
		
		override public function clone():Event
		{
			return new CompositeMetadataEvent
				( type , bubbles, cancelable
				, _child, _childMetadataNamespaceURL, _childMetadata
				, _metadataGroup, _suggestedMetadataSynthesizer
				);
		}
		
		// Internal
		//
		
		private var _child:Metadata;
		private var _childMetadataNamespaceURL:String;
		private var _childMetadata:Metadata;
		private var _metadataGroup:MetadataGroup;
		private var _suggestedMetadataSynthesizer:MetadataSynthesizer;
	}
}