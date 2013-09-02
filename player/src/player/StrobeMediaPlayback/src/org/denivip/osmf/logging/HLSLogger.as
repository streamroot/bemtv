package org.denivip.osmf.logging
{
	import flash.external.ExternalInterface;
	
	import mx.logging.Log;
	
	import org.osmf.logging.Logger;
	
	public class HLSLogger extends Logger
	{
		private var _handlers:Vector.<LogHandler>;
		public function HLSLogger(category:String, handlers:Vector.<LogHandler>){
			super(category);
			_handlers = handlers;
		}
		
		override public function debug(message:String, ...rest):void{ logMessage(LEVEL_DEBUG, message, rest); }
		
		override public function info(message:String, ...rest):void{ logMessage(LEVEL_INFO, message, rest); }
		
		override public function warn(message:String, ...rest):void{ logMessage(LEVEL_WARN, message, rest); }
		
		override public function error(message:String, ...rest):void{ logMessage(LEVEL_ERROR, message, rest); }
		
		override public function fatal(message:String, ...rest):void{ logMessage(LEVEL_FATAL, message, rest); }
		
		protected function logMessage(level:String, message:String, params:Array):void{
			for(var i:int = 0; i < _handlers.length; i++){
				var handler:LogHandler = _handlers[i];
				handler.handleMessage(new LogMessage(level, category, message, params));
			}
		}
		
		private static const LEVEL_DEBUG:String = "DEBUG";
		private static const LEVEL_WARN:String = "WARN";
		private static const LEVEL_INFO:String = "INFO";
		private static const LEVEL_ERROR:String = "ERROR";
		private static const LEVEL_FATAL:String = "FATAL";
	}
}