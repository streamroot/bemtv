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
package org.osmf.elements
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.elements.f4mClasses.Manifest;
	import org.osmf.elements.f4mClasses.ManifestParser;
	import org.osmf.elements.f4mClasses.builders.BaseManifestBuilder;
	import org.osmf.elements.f4mClasses.builders.MultiLevelManifestBuilder;
	import org.osmf.elements.f4mClasses.builders.ManifestBuilder;
	import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.ParseEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * ManifestLoader is a base loader class for objects that are capable of loading Flash Media Manifests
	 * either from F4M files or from the direct String representation of the manifest. 
	 * 
	 * @see http://opensource.adobe.com/wiki/display/osmf/Flash%2BMedia%2BManifest%2BFile%2BFormat%2BSpecification Flash Media Manifest File Format Specification
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.6
	 */
	public class ManifestLoaderBase extends LoaderBase
	{
		public function ManifestLoaderBase()
		{
			super();
		}
		
		/**
		 * @private
		 */
		protected function onParserTimerComplete(event:TimerEvent):void
		{
			if (parserTimer)
			{
				parserTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onParserTimerComplete);
				parserTimer = null;
			}
			
			// Parsing hasn't finished, so throw an error.
			updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
			loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(MediaErrorCodes.F4M_FILE_INVALID, OSMFStrings.getString(OSMFStrings.F4M_PARSE_ERROR))));
		}
		
		/**
		 * @private
		 */
		protected function onParserLoadComplete(event:ParseEvent):void
		{
			if (parserTimer)
			{
				parserTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onParserTimerComplete);
				parserTimer.stop();
				parserTimer = null;
			}
			
			parser.removeEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
			parser.removeEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);
			
			var manifest:Manifest = event.data as Manifest;
			finishManifestLoad(manifest);
		}
		
		/**
		 * @private
		 */
		protected function onParserLoadError(event:ParseEvent):void
		{
			if (parserTimer)
			{
				parserTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onParserTimerComplete);
				parserTimer.stop();
				parserTimer = null;
			}
			
			parser.removeEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
			parser.removeEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);
			
			updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
			loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(MediaErrorCodes.F4M_FILE_INVALID, OSMFStrings.getString(OSMFStrings.F4M_PARSE_ERROR))));
		}
		
		/**
		 * @private
		 */
		protected function finishManifestLoad(manifest:Manifest):void
		{
			try
			{
				var netResource:MediaResourceBase = parser.createResource(manifest, loadTrait.resource);
				var loadedElem:MediaElement = factory.createMediaElement(netResource);
				
				if (loadedElem.hasOwnProperty("defaultDuration") && !isNaN(manifest.duration))
				{
					loadedElem["defaultDuration"] = manifest.duration;
				}
				
				LoadFromDocumentLoadTrait(loadTrait).mediaElement = loadedElem;
				updateLoadTrait(loadTrait, LoadState.READY);
			}
			catch (error:Error)
			{
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(MediaErrorCodes.F4M_FILE_INVALID, error.message)));
			}
		}
		
		/**
		 * @private
		 */
		override protected function executeUnload(loadTrait:LoadTrait):void
		{
			updateLoadTrait(loadTrait, LoadState.UNINITIALIZED);
		}
		
		/**
		 * @private
		 * 
		 * Defines the <code>BaseManifestBuilder</code> objects used to create the <code>ManifestParser</code>.
		 *
		 * @return A <code>Vector</code> of <code>BaseManifestBuilder</code> objects.
		 * 
		 */
		protected function getBuilders():Vector.<BaseManifestBuilder>
		{
			var b:Vector.<BaseManifestBuilder> = new Vector.<BaseManifestBuilder>();
			
			b.push(new MultiLevelManifestBuilder());
			b.push(new ManifestBuilder());
			
			return b;
		}
		
		protected function getParser(resourceData:String):ManifestParser
		{
			var parser:ManifestParser;
			
			for each (var b:BaseManifestBuilder in builders)
			{
				if (b.canParse(resourceData))
				{
					parser = b.build(resourceData) as ManifestParser;
					break;
				}
			}
			
			return parser;
		}
		
		protected var factory:MediaFactory;
		
		protected var builders:Vector.<BaseManifestBuilder>;
		
		protected var loadTrait:LoadTrait;
		
		protected var parserTimer:Timer;
		
		protected var parser:ManifestParser;
	}
}