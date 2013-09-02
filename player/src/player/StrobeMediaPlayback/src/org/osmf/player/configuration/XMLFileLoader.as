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

package org.osmf.player.configuration
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	[Event(name="complete", type="flash.events.Event")]
	[Event(name="io_error", type="flash.events.IOErrorEvent")]
	[Event(name="security_error", type="flash.events.SecurityErrorEvent")]
	
	/**
	 * Loads an XML file.
	 */ 
	public class XMLFileLoader extends EventDispatcher
	{
		public function load(url:String):void
		{
			this.url = url;
			
			loader = new URLLoader();
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(Event.COMPLETE, completionSignalingHandler);
			loader.load(new URLRequest(url));
		}	
		
		public function get xml():XML
		{
			var xml:XML = null;
			try
			{
				xml = loader 
					? loader.data != null
						? new XML(loader.data)
						: null
					: null;
			} 
			catch (error:Error)
			{				
			}
			return xml;
		}
		
		// Internals
		//
		
		private function completionSignalingHandler(event:Event):void
		{			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function errorHandler(event:Event):void
		{			
			dispatchEvent(event.clone());
			
			// Uncomment the line below to see the global exception handling in action.
			//throw new Error("Failed to load XML file at " + url);
		}
		
		private var loader:URLLoader;
		private var url:String;
	}
}