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
package org.osmf.elements.proxyClasses
{
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	
	import org.osmf.metadata.Metadata;
	import org.osmf.events.MetadataEvent;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Internal class used by the ProxyElement to proxy metadata.
	 */ 
	public class ProxyMetadata extends Metadata
	{
		public function ProxyMetadata()
		{
			proxiedMetadata = new Metadata();
			proxiedMetadata.addEventListener(MetadataEvent.VALUE_ADD, redispatchEvent);
			proxiedMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, redispatchEvent);
			proxiedMetadata.addEventListener(MetadataEvent.VALUE_REMOVE, redispatchEvent);	
		}
			
		public function set metadata(value:Metadata):void
		{
			// Remove old listeners.
			proxiedMetadata.removeEventListener(MetadataEvent.VALUE_ADD, redispatchEvent);
			proxiedMetadata.removeEventListener(MetadataEvent.VALUE_CHANGE, redispatchEvent);
			proxiedMetadata.removeEventListener(MetadataEvent.VALUE_REMOVE, redispatchEvent);	

			// Transfer all old values to new.
			for each (var url:String in proxiedMetadata.keys)
			{
				value.addValue(url, proxiedMetadata.getValue(url));
			}
			proxiedMetadata = value;
			
			// Add new listeners.		
			proxiedMetadata.addEventListener(MetadataEvent.VALUE_ADD, redispatchEvent);
			proxiedMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, redispatchEvent);
			proxiedMetadata.addEventListener(MetadataEvent.VALUE_REMOVE, redispatchEvent);	
		}
		
		/** 
		 * @private
		 */ 
		override public function getValue(key:String):*
		{				
			return proxiedMetadata.getValue(key);		
		}
		
		/** 
		 * @private
		 */ 
		override public function addValue(key:String, value:Object):void
		{
			proxiedMetadata.addValue(key, value);						
		}
		
		/** 
		 * @private
		 */ 
		override public function removeValue(key:String):*
		{			
			return proxiedMetadata.removeValue(key);
		}	
			
		/** 
		 * @private
		 */ 
		override public function get keys():Vector.<String>
		{			
			return proxiedMetadata.keys;
		}
			
		private function redispatchEvent(event:Event):void
		{
			dispatchEvent(event.clone());
		}
				
		private var proxiedMetadata:Metadata;
	}
}