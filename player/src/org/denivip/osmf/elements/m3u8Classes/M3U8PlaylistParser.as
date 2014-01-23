package org.denivip.osmf.elements.m3u8Classes
{
	import flash.events.EventDispatcher;
	
	import org.denivip.osmf.net.HLSDynamicStreamingResource;
	import org.denivip.osmf.utility.Url;
	import org.osmf.events.ParseEvent;
	import org.osmf.logging.Log;
	import org.osmf.logging.Logger;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.MediaType;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.StreamType;
	import org.osmf.net.StreamingItem;
	import org.osmf.net.StreamingURLResource;
	
	
	[Event(name="parseComplete", type="org.osmf.events.ParseEvent")]
	[Event(name="parseError", type="org.osmf.events.ParseEvent")]
	
	/**
	 * You will not belive, but this class parses *.m3u8 playlist 
	 */
	public class M3U8PlaylistParser extends EventDispatcher
	{
		public function M3U8PlaylistParser(){
			// nothing todo here...
		}
		
		public function parse(value:String, baseResource:URLResource):void{
			
			if(!value || value == ''){
				throw new ArgumentError("Parsed value is missing =(");
			}
			
			var lines:Array = value.split(/\r?\n/);
			
			if(lines[0] != '#EXTM3U'){
				;
				CONFIG::LOGGING
				{
					logger.warn('Incorrect header! {0}', lines[0]);
				}
			}
			
			var result:MediaResourceBase;
			var isLive:Boolean = true;
			var streamItems:Vector.<DynamicStreamingItem>;
			var tempStreamingRes:StreamingURLResource = null;
			var tempDynamicRes:DynamicStreamingResource = null;
			var alternateStreams:Vector.<StreamingItem> = null;
			var initialStreamName:String = '';
			for(var i:int = 1; i < lines.length; i++){
				var line:String = String(lines[i]).replace(/^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2");
				
				if(line.indexOf("#EXTINF:") == 0){
					result = baseResource;
					tempStreamingRes = result as StreamingURLResource;
					
					if(tempStreamingRes && tempStreamingRes.streamType == StreamType.LIVE_OR_RECORDED){
						for(var j:int = i+1; j < lines.length; j++){
							if(String(lines[j]).indexOf('#EXT-X-ENDLIST') == 0){
								isLive = false;
								break;
							}
						}
						if(isLive)
							tempStreamingRes.streamType = StreamType.LIVE;
					}
					break;
				}
				
				if(line.indexOf("#EXT-X-STREAM-INF:") == 0){
					if(!result){
						result = new HLSDynamicStreamingResource(baseResource.url);
						tempDynamicRes = result as DynamicStreamingResource;
						tempStreamingRes = baseResource as StreamingURLResource;
						if(tempStreamingRes){
							tempDynamicRes.streamType = tempStreamingRes.streamType;
							tempDynamicRes.clipStartTime = tempStreamingRes.clipStartTime;
							tempDynamicRes.clipEndTime = tempStreamingRes.clipEndTime;
						}
						streamItems = new Vector.<DynamicStreamingItem>();
					}
					
					var bw:Number;
					if(line.search(/BANDWIDTH=(\d+)/) > 0)
						bw = parseFloat(line.match(/BANDWIDTH=(\d+)/)[1])/1000;
					
					var width:int = -1;
					var height:int = -1;
					if(line.search(/RESOLUTION=(\d+)x(\d+)/) > 0){
						width = parseInt(line.match(/RESOLUTION=(\d+)x(\d+)/)[1]);
						height = parseInt(line.match(/RESOLUTION=(\d+)x(\d+)/)[2]);
					}
					
					var name:String = lines[i+1];
					streamItems.push(new DynamicStreamingItem(name, bw, width, height));
					// store stream name of first stream encountered
					if(initialStreamName == ''){
						initialStreamName = name;
					}
					DynamicStreamingResource(result).streamItems = streamItems;
				}
				
				if(line.indexOf("#EXT-X-MEDIA:") == 0){
					if(line.search(/TYPE=(.*?)\W/) > 0 && line.match(/TYPE=(.*?)\W/)[1] == 'AUDIO'){
						var stUrl:String;
						var lang:String;
						var stName:String;
						if(line.search(/URI="(.*?)"/) > 0){
							stUrl = line.match(/URI="(.*?)"/)[1];
							if(stUrl.search(/(file|https?):\/\//) != 0){
								stUrl = baseResource.url.substr(0, baseResource.url.lastIndexOf('/')+1) + stUrl;
							}
						}
						if(line.search(/LANGUAGE="(.*?)"/) > 0){
							lang = line.match(/LANGUAGE="(.*?)"/)[1]
						}
						if(line.search(/NAME="(.*?)"/) > 0){
							stName = line.match(/NAME="(.*?)"/)[1];
						}
						if(!alternateStreams)
							alternateStreams = new Vector.<StreamingItem>();
						
						alternateStreams.push(
							new StreamingItem(MediaType.AUDIO, stUrl, 0, {label:stName, language:lang})
						);
					}
				}
			}
			
			if(tempDynamicRes && tempDynamicRes.streamItems){
				if(tempDynamicRes.streamItems.length == 1){
					tempStreamingRes = baseResource as StreamingURLResource;
					if(tempStreamingRes){
						// var url:String = (lines[i].search(/(ftp|file|https?):\/\//) == 0) ?  lines[i] : rateItem.url.substr(0, rateItem.url.lastIndexOf('/')+1) + lines[i];
						/*
						var url:String = (tempDynamicRes.streamItems[0].streamName.search(/(ftp|file|https?):\/\//) == 0) 
							? tempDynamicRes.streamItems[0].streamName 
							: tempDynamicRes.host.substr(0, tempDynamicRes.host.lastIndexOf('/')+1) + tempDynamicRes.streamItems[0].streamName;
						*/
						var url:String = Url.absolute(tempDynamicRes.host, tempDynamicRes.streamItems[0].streamName);
						result = new StreamingURLResource(
							url,
							tempStreamingRes.streamType,
							tempStreamingRes.clipStartTime,
							tempStreamingRes.clipEndTime,
							tempStreamingRes.connectionArguments,
							tempStreamingRes.urlIncludesFMSApplicationInstance,
							tempStreamingRes.drmContentData
						);
					}
				}else{
					if(baseResource.getMetadataValue(MetadataNamespaces.RESOURCE_INITIAL_INDEX) != null){
						var initialIndex:int = baseResource.getMetadataValue(MetadataNamespaces.RESOURCE_INITIAL_INDEX) as int;
						tempDynamicRes.initialIndex = initialIndex < 0 ? 0 : (initialIndex >= tempDynamicRes.streamItems.length) ? (tempDynamicRes.streamItems.length-1) : initialIndex;
					}else{
						// set initialIndex to index of first stream name encountered
						tempDynamicRes.initialIndex = tempDynamicRes.indexFromName(initialStreamName);
					}
				}
			}
			
			baseResource.addMetadataValue("HLS_METADATA", new Metadata()); // fix for multistreaming resources
			result.addMetadataValue("HLS_METADATA", new Metadata());
			
			var httpMetadata:Metadata = new Metadata();
			result.addMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA, httpMetadata);
			
			if(alternateStreams && result is StreamingURLResource){
				(result as StreamingURLResource).alternativeAudioStreamItems = alternateStreams;
			}
			
			if(result is StreamingURLResource && StreamingURLResource(result).streamType == StreamType.DVR){
				var dvrMetadata:Metadata = new Metadata();
				result.addMetadataValue(MetadataNamespaces.DVR_METADATA, dvrMetadata);
			}
			
			dispatchEvent(new ParseEvent(ParseEvent.PARSE_COMPLETE, false, false, result));
		}
		/*
		private function addDVRInfo():void{
			
			CONFIG::LOGGING
			{
				logger.info('DVR!!! \\o/'); // we happy!
			}
			
			// black magic...
			var dvrInfo:DVRInfo = new DVRInfo();
			dvrInfo.id = dvrInfo.url = '';
			dvrInfo.isRecording = true; // if live then in process
			//dvrInfo.startTime = 0.0;
			// attach info into playlist
		}
		*/
		CONFIG::LOGGING
		{
			private var logger:Logger = Log.getLogger("org.denivip.osmf.elements.m3u8Classes.M3U8PlaylistParser");
		}
	}
}
