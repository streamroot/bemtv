package org.denivip.osmf.logging
{
	import flash.utils.Dictionary;
	
	import org.osmf.logging.Logger;
	import org.osmf.logging.LoggerFactory;
	
	public class HLSLoggerFactory extends LoggerFactory
	{
		private var _loggers:Dictionary;
		private var _handlers:Vector.<LogHandler>;
		
		public function HLSLoggerFactory(handlers:Vector.<LogHandler>)
		{
			_loggers = new Dictionary();
			_handlers = handlers;
		}
		
		override public function getLogger(category:String):Logger{
			var logger:HLSLogger = _loggers[category];
			
			if(logger == null){
				logger = new HLSLogger(category, _handlers);
				_loggers[category] = logger;
			}
			
			return logger;
		}
	}
}