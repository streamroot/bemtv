package org.denivip.osmf.net.httpstreaming.hls
{
	
	import org.osmf.net.httpstreaming.HTTPStreamDownloader;
	import flash.external.ExternalInterface;


	public class HTTPBenTVDownloader extends HTTPStreamDownloader
	{
		
		public function HTTPBenTVDownloader() {
			ExternalInterface.call("console.log", "To no jogo...");
			super();
		}
		
	}
}