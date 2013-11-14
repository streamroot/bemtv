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
  public class BemTVURLStream extends URLStream
  {
    private var bemtvBuffer:ByteArray = new ByteArray();
    private var _connected:Boolean;

    public function BemTVURLStream() {
      addEventListener(Event.OPEN, onOpen);
      addEventListener(Event.COMPLETE, onComplete);
      addEventListener(ProgressEvent.PROGRESS, onProgress);
      addEventListener(IOErrorEvent.IO_ERROR, onError);
      addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
      ExternalInterface.addCallback("resourceLoaded", resourceLoaded);
      super();
    }

    private function onOpen(event:Event):void {
      _connected = true;
    }

    private function onComplete(event:Event):void {
    }

    private function onProgress(event:Event):void {
    }

    private function onError(event:Event):void {
      ExternalInterface.call('console.log', 'Event.ERROR'  + event);
    }

    override public function get connected ():Boolean {
      return _connected;
    }

    override public function get bytesAvailable ():uint {
      return bemtvBuffer.bytesAvailable;
    }

    override public function close ():void {
    }

    override public function load(request:URLRequest):void {
      ExternalInterface.call("bemtvConnector.requestResource", request.url);
      dispatchEvent(new Event(Event.OPEN));
    }

    public function resourceLoaded(resource:String):void {
      bemtvBuffer = Base64.decodeToByteArray(resource);
      bemtvBuffer.position = 0;
      dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bemtvBuffer.bytesAvailable, bemtvBuffer.bytesAvailable));
      dispatchEvent(new Event(Event.COMPLETE));
    }

    override public function readByte():int {
      return bemtvBuffer.readByte();
    }

    override public function readUnsignedShort():uint {
      return bemtvBuffer.readUnsignedShort();
    }

    override public function readBytes(bytes:ByteArray, offset:uint = 0, length:uint = 0):void {
        bemtvBuffer.readBytes(bytes, offset, length);
    }
  }
}

