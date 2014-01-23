/* ***** BEGIN LICENSE BLOCK *****
* Version: MPL 1.1
*
* The contents of this file are subject to the Mozilla Public License Version
* 1.1 (the "License"); you may not use this file except in compliance with
* the License. You may obtain a copy of the License at
* http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is the at.matthew.httpstreaming package.
*
* The Initial Developer of the Original Code is
* Matthew Kaufman.
* Portions created by the Initial Developer are Copyright (C) 2011
* the Initial Developer. All Rights Reserved.
*
* Contributor(s):
*
* ***** END LICENSE BLOCK ***** */

package org.denivip.osmf.net.httpstreaming.hls
{
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.httpstreaming.HTTPStreamingFactory;
	import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
	import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;
	
	/**
	 * HLS Streaming factory
	 */
	public class HTTPStreamingHLSFactory extends HTTPStreamingFactory
	{
		public function HTTPStreamingHLSFactory()
		{
			super();
		}
		
		override public function createFileHandler(resource:MediaResourceBase):HTTPStreamingFileHandlerBase
		{	
			return new HTTPStreamingMP2TSFileHandler();
		}
		override public function createIndexHandler(resource:MediaResourceBase, fileHandler:HTTPStreamingFileHandlerBase):HTTPStreamingIndexHandlerBase
		{
			return new HTTPStreamingHLSIndexHandler(fileHandler as HTTPStreamingMP2TSFileHandler);
		}
		
		override public function createIndexInfo(resource:MediaResourceBase):HTTPStreamingIndexInfoBase
		{
			return createHLSIndexInfo(URLResource(resource));
		}
		
		private function createHLSIndexInfo(res:URLResource):HTTPStreamingHLSIndexInfo{
			
			var baseURL:String = '';
			var streamInfos:Vector.<HLSStreamInfo> = new Vector.<HLSStreamInfo>();
			var dynamicRes:DynamicStreamingResource;
			
			if(res is DynamicStreamingResource){
				dynamicRes = res as DynamicStreamingResource;
				
				for each(var dsi:DynamicStreamingItem in dynamicRes.streamItems){
					streamInfos.push(new HLSStreamInfo(dsi.streamName, dsi.bitrate));
				}
				
				baseURL = dynamicRes.host;
			}else{
				streamInfos.push(new HLSStreamInfo(res.url, 0));
			}
			
			return new HTTPStreamingHLSIndexInfo(baseURL, streamInfos);
		
		}
	}
}