	package org.denivip.osmf.net.httpstreaming.hls
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Decoder;
	/**
	 * Dispatched when data is received as the download operation progresses.
	 * @eventType flash.events.ProgressEvent.PROGRESS
	 */
	[Event(name="progress", type="flash.events.ProgressEvent")] 
	
	/**
	 * Dispatched when a load operation starts.
	 * @eventType flash.events.Event.OPEN
	 */
	[Event(name="open", type="flash.events.Event")] 
	
	/**
	 * Dispatched when an input/output error occurs that causes a load operation to fail.
	 * @eventType flash.events.IOErrorEvent.IO_ERROR
	 */
	[Event(name="ioError", type="flash.events.IOErrorEvent")] 
	
	/**
	 * Dispatched if a call to the URLStream.load() method attempts to access data over HTTP and Adobe AIR is able to detect and return the status code for the request.
	 * @eventType flash.events.HTTPStatusEvent.HTTP_RESPONSE_STATUS
	 */
	[Event(name="httpResponseStatus", type="flash.events.HTTPStatusEvent")] 
	
	/**
	 * Dispatched if a call to URLStream.load() attempts to access data over HTTP, and Flash Player or  or Adobe AIR is able to detect and return the status code for the request.
	 * @eventType flash.events.HTTPStatusEvent.HTTP_STATUS
	 */
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")] 
	
	/**
	 * Dispatched if a call to URLStream.load() attempts to load data from a server outside the security sandbox.
	 * @eventType flash.events.SecurityErrorEvent.SECURITY_ERROR
	 */
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")] 
	
	/**
	 * Dispatched when data has loaded successfully.
	 * @eventType flash.events.Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")] 
	
	/// The URLStream class provides low-level access to downloading URLs.
	public class BenTVURLStream extends URLStream
	{
		private var myBytes:ByteArray = new ByteArray();
		private var _bytesAvailable:uint;
		private var _connected:Boolean;
		
		public function BenTVURLStream() {
			addEventListener(Event.OPEN, onOpen);
			addEventListener(Event.COMPLETE, onComplete);
			addEventListener(ProgressEvent.PROGRESS, onProgress);
			addEventListener(IOErrorEvent.IO_ERROR, onError);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			super();
		}
		
		private function onOpen(event:Event):void {
			ExternalInterface.call('console.log', 'Event.OPEN ' + event);
			_connected = true;
		}
		
		private function onComplete(event:Event):void {
			ExternalInterface.call('console.log', 'Event.COMPLETE' + event);
		}
		
		private function onProgress(event:Event):void {
			ExternalInterface.call('console.log', 'Event.PROGRESS' + event);
		}
		
		private function onError(event:Event):void {
			ExternalInterface.call('console.log', 'Event.ERROR'  + event);
		}
		
		override public function get connected ():Boolean {
			ExternalInterface.call("console.log", "BenTVURLStream - connected called " + _connected);
			//return _connected;
			return super.connected;
		}
		
		/// Returns the number of bytes of data available for reading in the input buffer.
		override public function get bytesAvailable ():uint {
			//ExternalInterface.call("console.log", "bytesAvailable called " + _bytesAvailable);
			return super.bytesAvailable;
			//return _bytesAvailable;
		}

		/// Immediately closes the stream and cancels the download operation.
		override public function close ():void {
			ExternalInterface.call("console.log", "BenTVURLStream - close called ");	
			super.close();
		}
		
		/// Begins downloading the URL specified in the request parameter.
		override public function load(request:URLRequest):void {
			ExternalInterface.call("console.log", "BenTVURLStream - load called " + request.url);
//			_bytesAvailable = ExternalInterface.call("loadUrl", request.url);
//			ExternalInterface.call("console.log", "BenTVURLStream - Downloaded " + _bytesAvailable);
//			dispatchEvent(new Event(Event.OPEN));
//			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _bytesAvailable, _bytesAvailable));
//			dispatchEvent(new Event(Event.COMPLETE));
			super.load(request);			
		}		
		
		/// Reads length bytes of data from the stream.
		override public function readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void {
			ExternalInterface.call("console.log", "position: " + bytes.position + " bytes:" + bytes.toString());
			//ExternalInterface.call("console.log", "BenTVURLStream - readBytes " + length + " " + offset);
			super.readBytes(bytes, offset, length);
			ExternalInterface.call("console.log", "position: " + bytes.position + " bytes:" + bytes.toString());
//			myBytes = Base64.decodeToByteArray(ExternalInterface.call("readBytes"));
//			bytes.writeObject(myBytes);
//			//bytes.position = 0;
//			ExternalInterface.call("console.log", myBytes.toString());
		}		
	}
}
	
	