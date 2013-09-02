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
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
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
	import org.osmf.media.MediaTypeUtil;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.httpstreaming.HTTPStreamingUtils;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	import org.osmf.utils.OSMFSettings;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;

	/**
	 * F4MLoader is a loader that is capable of loading F4M files.  F4M files are
	 * XML documents that adhere to the Flash Media Manifest format, and which
	 * represent all of the information needed to load and play a media file.
	 *
	 * @see http://opensource.adobe.com/wiki/display/osmf/Flash%2BMedia%2BManifest%2BFile%2BFormat%2BSpecification Flash Media Manifest File Format Specification
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class F4MLoader extends LoaderBase
	{
		/**
		 * The MIME type for F4M files.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public static const F4M_MIME_TYPE:String = "application/f4m+xml";

		/**
		 * Constructor.
		 *
		 * @param factory The factory that is used to create MediaElements based on the
		 * media specified in the manifest file.  If no factory is provided, the F4MLoader
		 * will use a DefaultMediaFactory.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function F4MLoader(factory:MediaFactory = null)
		{
			super();

			supportedMimeTypes.push(F4M_MIME_TYPE);
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
			var supported:int = MediaTypeUtil.checkMetadataMatchWithResource(resource, new Vector.<String>(), supportedMimeTypes);

			if (supported == MediaTypeUtil.METADATA_MATCH_FOUND)
			{
				return true;
			}
			else if (resource is URLResource)
			{
				// FIX for FM-1167 (http://bugs.adobe.com/jira/browse/FM-1167)
				// If the url contains a ".f4m" in path part, it will be handled twice 
				// by the F4MLoaded. Check to see if the .f4m file hasn't been processed before.
				if (resource is DynamicStreamingResource)
				{
					var dynResource:DynamicStreamingResource = DynamicStreamingResource(resource);
					if (dynResource.streamItems.length > 0)
						return false;
				}

				var urlResource:URLResource = URLResource(resource);
				var extension:String = new URL(urlResource.url).extension;
				return extension == F4M_EXTENSION;
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
			var manifestLoader:URLLoader = new URLLoader(new URLRequest(URLResource(loadTrait.resource).url));
			manifestLoader.addEventListener(Event.COMPLETE, onComplete);
			manifestLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			manifestLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

			function onError(event:ErrorEvent):void
			{
				manifestLoader.removeEventListener(Event.COMPLETE, onComplete);
				manifestLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				manifestLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

				updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
				loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(0, event.text)));
			}

			function onComplete(event:Event):void
			{
				manifestLoader.removeEventListener(Event.COMPLETE, onComplete);
				manifestLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				manifestLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

				try
				{
					var resourceData:String = String((event.target as URLLoader).data);

					parser = getParser(resourceData);

					// Begin parsing.
					parser.addEventListener(ParseEvent.PARSE_COMPLETE, onParserLoadComplete);
					parser.addEventListener(ParseEvent.PARSE_ERROR, onParserLoadError);

					// Set up the timeout.
					parserTimer = new Timer(OSMFSettings.f4mParseTimeout, 1);
					parserTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onParserTimerComplete);
					parserTimer.start();

					parser.parse(resourceData, URL.getRootUrl(URLResource(loadTrait.resource).url));
				}
				catch (parseError:Error)
				{
					updateLoadTrait(loadTrait, LoadState.LOAD_ERROR);
					loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, new MediaError(parseError.errorID, parseError.message)));
				}
			}
		}

		private function onParserTimerComplete(event:TimerEvent):void
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

		private function onParserLoadComplete(event:ParseEvent):void
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

		private function onParserLoadError(event:ParseEvent):void
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

		private function finishManifestLoad(manifest:Manifest):void
		{
			try
			{
				var netResource:MediaResourceBase = parser.createResource(manifest, URLResource(loadTrait.resource));
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
		 * Defines the <code>BaseManifestBuilder</code> objects used to create the <code>ManifestParser</code>.
		 *
		 * @return A <code>Vector</code> of <code>BaseManifestBuilder</code> objects.
		 */
		protected function getBuilders():Vector.<BaseManifestBuilder>
		{
			var b:Vector.<BaseManifestBuilder> = new Vector.<BaseManifestBuilder>();

			b.push(new MultiLevelManifestBuilder());
			b.push(new ManifestBuilder());

			return b;
		}

		private function getParser(resourceData:String):ManifestParser
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

		private static const F4M_EXTENSION:String = "f4m";

		private var supportedMimeTypes:Vector.<String> = new Vector.<String>();

		private var factory:MediaFactory;

		private var parser:ManifestParser;

		private var parserTimer:Timer;

		private var builders:Vector.<BaseManifestBuilder>;

		private var loadTrait:LoadTrait;
	}
}