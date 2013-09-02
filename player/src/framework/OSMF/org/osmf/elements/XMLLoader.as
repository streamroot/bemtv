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
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	
	import org.osmf.elements.f4mClasses.DRMAdditionalHeader;
	import org.osmf.elements.f4mClasses.Manifest;
	import org.osmf.elements.f4mClasses.ManifestParser;
	import org.osmf.elements.f4mClasses.builders.BaseManifestBuilder;
	import org.osmf.elements.f4mClasses.builders.ManifestBuilder;
	import org.osmf.elements.f4mClasses.builders.MultiLevelManifestBuilder;
	import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.ParseEvent;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.StreamingXMLResource;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.OSMFSettings;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * XMLLoader is a loader that is capable of loading F4M Strings. F4M files are
	 * XML documents that adhere to the Flash Media Manifest format, and which
	 * represent all of the information needed to load and play a media file.
	 *
	 * @see http://opensource.adobe.com/wiki/display/osmf/Flash%2BMedia%2BManifest%2BFile%2BFormat%2BSpecification Flash Media Manifest File Format Specification
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.6
	 */
	public class XMLLoader extends ManifestLoaderBase
	{
		public function XMLLoader(factory:MediaFactory = null)
		{
			super();
			
			if (factory == null)
			{
				factory = new DefaultMediaFactory();
			}
			
			this.factory = factory;
			
			this.builders = getBuilders();
		}
		
		/**
		 * @private
		 */
		override public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			if (resource is StreamingXMLResource)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function executeLoad(loadTrait:LoadTrait):void
		{
			this.loadTrait = loadTrait;
			updateLoadTrait(loadTrait, LoadState.LOADING);
			var manifest:Manifest;
			
			try
			{
				var resourceData:String = (loadTrait.resource as StreamingXMLResource).manifest;
				
				parser = getParser(resourceData);
				
				// Begin parsing.
				parser.addEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
				parser.addEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);
				
				// Set up the timeout.
				parserTimer = new Timer(OSMFSettings.f4mParseTimeout, 1);
				parserTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onParserTimerComplete);
				parserTimer.start();
				
				parser.parse(resourceData, URL.getRootUrl(StreamingXMLResource(loadTrait.resource).url));
			}
			catch (parseError:Error)
			{
				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(parseError.errorID, parseError.message)));
			}
		}
		
	}
}