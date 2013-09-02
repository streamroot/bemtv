package org.osmf.player.chrome{
	import flash.events.IEventDispatcher;
	
	import org.osmf.layout.ILayoutTarget;
	import org.osmf.media.MediaElement;
	import org.osmf.player.chrome.assets.AssetsManager;
	
	/**
	 * IControlBar
	 * @author johncblandii
	 */
	public interface IControlBar extends ILayoutTarget, IEventDispatcher{
		// PROPERTIES
		//
		function get width():Number; function set width(value:Number):void;
		function get height():Number; function set height(value:Number):void;
		function get autoHide():Boolean; function set autoHide(value:Boolean):void;
		function get autoHideTimeout():int; function set autoHideTimeout(value:int):void;
		function get media():MediaElement; function set media(value:MediaElement):void;
		function get tintColor():uint; function set tintColor(value:uint):void;
		function get visible():Boolean; function set visible(value:Boolean):void;
		
		// FUNCTIONS
		//
		function configure(xml:XML, assetManager:AssetsManager):void;
	}
}