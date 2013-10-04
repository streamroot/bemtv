package org.denivip.osmf.elements.m3u8Classes
{
	/**
	 * Simple playlist item
	 */
	public class M3U8Item
	{
		protected var _duration:Number;
		protected var _url:String;
		protected var _startTime:Number;
		protected var _discontinuity:Boolean = false;
		
		private var _width:int = -1;
		private var _height:int = -1;
		
		/**
		 * Chunk bitrate (kbps)
		 */
		public var bandwidth:Number;
		
		/**
		 * Chunk resolution (just for info)
		 */
		public var resolution:String;
		
		
		public function M3U8Item(duration:Number, url:String, discontinuity:Boolean=false){
			_url = url;
			_duration = duration;
			_discontinuity = discontinuity;
		}

		/**
		 * Chunk duration
		 */
		public function get duration():Number{
			return _duration;
		}

		/**
		 * Chunk url (for loader)
		 */
		public function get url():String{
			return _url;
		}
		
		/**
		 * Frame width (in multiquality playlists)
		 */
		public function get width():int{
			if(resolution != null && _width == -1){
				_width = parseInt(resolution.split('x')[0]);
			}
			
			return _width;
		}
		
		/**
		 * Frame height (in multiquality playlists)
		 */
		public function get height():int{
			if(resolution != null && _height == -1){
				_height = parseInt(resolution.split('x')[1]);
			}
			
			return _height;
		}
		
		/**
		 * Fragment start time
		 */
		public function get startTime():Number{
			return _startTime;
		}
		
		public function set startTime(value:Number):void{
			_startTime = value;
		}
		
		public function get discontinuity():Boolean{
			return _discontinuity;
		}
	}
}