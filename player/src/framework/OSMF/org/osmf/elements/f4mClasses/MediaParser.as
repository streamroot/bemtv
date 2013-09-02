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
package org.osmf.elements.f4mClasses
{
	import flash.utils.ByteArray;

	import org.osmf.events.ParseEvent;
	import org.osmf.net.StreamingItemType;
	import org.osmf.utils.OSMFStrings;
	import org.osmf.utils.URL;

	[ExcludeClass]

	[Event(name="parseComplete", type="org.osmf.events.ParseEvent")]
	[Event(name="parseError", type="org.osmf.events.ParseEvent")]

	/**
	 * @private
	 *
	 * Parses media XML.
	 */
	public class MediaParser extends BaseParser
	{
		/**
		 * Constructor.
		 */
		public function MediaParser()
		{

		}

		/**
		 * @private
		 */
		override public function parse(value:String, baseURL:String = null, idPrefix:String = ""):void
		{
			var root:XML = new XML(value);

			if (!root)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_VALUE_MISSING));
			}

			var media:Media = new Media();

			var nmsp:Namespace = root.namespace();
			var decoder:Base64Decoder;

			if (root.attribute('url').length() > 0)
			{
				var url:String = root.@url;
				if (!URL.isAbsoluteURL(url))
				{
					url = URL.normalizeRootURL(baseURL) + URL.normalizeRelativeURL(url);
				}
				media.url = url;
			}
			// Raise parse error
			else
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_MEDIA_URL_MISSING));
			}

			if (root.attribute('bitrate').length() > 0)
			{
				media.bitrate = root.@bitrate;
			}

			if (root.attribute('drmAdditionalHeaderId').length() > 0)
			{
				media.drmAdditionalHeader = new DRMAdditionalHeader();
				media.drmAdditionalHeader.id = idPrefix + root.@drmAdditionalHeaderId;
			}

			if (root.attribute('bootstrapInfoId').length() > 0)
			{
				media.bootstrapInfo = new BootstrapInfo();
				media.bootstrapInfo.id = idPrefix + root.@bootstrapInfoId;
			}

			if (root.attribute('height').length() > 0)
			{
				media.height = root.@height;
			}

			if (root.attribute('width').length() > 0)
			{
				media.width = root.@width;
			}

			if (root.attribute('groupspec').length() > 0)
			{
				media.multicastGroupspec = root.@groupspec;
			}

			if (root.attribute('multicastStreamName').length() > 0)
			{
				media.multicastStreamName = root.@multicastStreamName;
			}

			if (root.attribute('label').length() > 0)
			{
				media.label = root.@label;
			}

			if (root.attribute('type').length() > 0)
			{
				media.type = root.@type;
			}
			else
			{
				media.type = StreamingItemType.VIDEO;
			}

			if (root.attribute('lang').length() > 0)
			{
				media.language = root.@lang;
			}

			if (root.hasOwnProperty("@alternate") || root.attribute('alternate').length() > 0)
			{
				media.alternate = true;
			}

			if (root.nmsp::moov.length() > 0)
			{
				decoder = new Base64Decoder();
				decoder.decode(root.nmsp::moov.text());
				media.moov = decoder.drain();
			}

			if (root.nmsp::metadata.length() > 0)
			{
				decoder = new Base64Decoder();
				decoder.decode(root.nmsp::metadata.text());

				var data:ByteArray = decoder.drain();
				data.position = 0;
				data.objectEncoding = 0;

				try
				{
					var header:String = data.readObject() as String;
					var metaInfo:Object = data.readObject();
					media.metadata = metaInfo;

					// if width and height are not already set by the media
					// attributes and they are already present in metadata 
					// object, then copy their values to the media properties
					if ((isNaN(media.width) || media.width == 0) && media.metadata.hasOwnProperty("width"))
					{
						media.width = media.metadata["width"];
					}
					if ((isNaN(media.height) || media.height == 0) && media.metadata.hasOwnProperty("height"))
					{
						media.height = media.metadata["height"];
					}
				}
				catch (e:Error)
				{

				}
			}

			if (root.nmsp::xmpMetadata.length() > 0)
			{
				decoder = new Base64Decoder();
				decoder.decode(root.nmsp::xmpMetadata.text());
				media.xmp = decoder.drain();
			}

			validateMedia(media);
			finishLoad(media);
		}

		/**
		 * Checks if the media is valid.
		 *
		 * @param media
		 *
		 * @private
		 * In protected scope so that subclasses can change validation.
		 */
		protected function validateMedia(media:Media):void
		{
			if (media && (media.multicastGroupspec != null && media.multicastGroupspec.length > 0 && (media.multicastStreamName == null || media.multicastStreamName.length <= 0)) || (media.multicastStreamName != null && media.multicastStreamName.length > 0 && (media.multicastGroupspec == null || media.multicastGroupspec.length <= 0)))
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.MULTICAST_PARAMETER_INVALID));
			}
		}

		/**
		 * Finishes loading a parsed object.
		 *
		 * @param media The completed <code>Media</code> object.
		 *
		 * @private
		 * In protected scope so that subclasses have an opportunity to do
		 * stuff before loading finishes.
		 */
		protected function finishLoad(media:Media):void
		{
			if (!media)
			{
				return;
			}

			dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, false, false, media));
		}
	}
}