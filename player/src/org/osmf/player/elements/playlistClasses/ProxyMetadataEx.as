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

// NB:
// This is a monkey-patched version of the OSMF's ProxyMetadata, fixing bug FM-933.

package org.osmf.player.elements.playlistClasses
{
	import __AS3__.vec.Vector;
	
	import flash.events.Event;
	
	import org.osmf.metadata.Metadata;
	import org.osmf.events.MetadataEvent;
	import org.osmf.elements.proxyClasses.ProxyMetadata;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Internal class used by the FactoryElement to proxy metadata.
	 */ 
	public class ProxyMetadataEx extends ProxyMetadata
	{
		public function ProxyMetadataEx()
		{
			super();
			
			proxiedMetadata = new Metadata();
			
			// The listeners below don't get added by the original class, and fix
			// initial changes not being dispatched:
			proxiedMetadata.addEventListener(MetadataEvent.VALUE_ADD, redispatchEvent);
			proxiedMetadata.addEventListener(MetadataEvent.VALUE_CHANGE, redispatchEvent);
			proxiedMetadata.addEventListener(MetadataEvent.VALUE_REMOVE, redispatchEvent);	
		}
		
		override public function set metadata(value:Metadata):void
		{			
			
			// Transfer all old values to new:
			for each (var url:String in proxiedMetadata.keys)
			{
				value.addValue(url, proxiedMetadata.getValue(url));
			}			
			proxiedMetadata = value;		
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