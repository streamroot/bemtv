package tv.bem {
  import flash.net.URLRequest;
  import flash.events.Event;
  import flash.external.ExternalInterface;
  import org.mangui.chromeless.JSURLStream;

  public class BemTVURLStream extends JSURLStream
  {
    public function BemTVURLStream() {
      super();
    }

    override public function load(request:URLRequest):void {
      ExternalInterface.call("player.core.containers[0].getPluginByName('bemtv_p2p_video_playback').requestResource", request.url);
      dispatchEvent(new Event(Event.OPEN));
    }
  }
}

