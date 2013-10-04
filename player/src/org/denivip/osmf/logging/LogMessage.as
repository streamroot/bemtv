package org.denivip.osmf.logging
{
	internal class LogMessage
	{
		private var _level:String;
		private var _category:String;
		private var _message:String;
		private var _params:Array;
		
		private var _logMessage:String;
		
		public function LogMessage(level:String, category:String, message:String, params:Array){
			_level = level;
			_category = category;
			_message = message;
			_params = params;
			
			_logMessage = buildLogString();
		}
		
		public function get level():String{ return _level; }
		
		public function get category():String{ return _category; }
		
		public function get message():String{ return _message; }
		
		public function get params():Array{ return _params; }
		
		public function toString():String{
			return _logMessage;
		}
		
		private function buildLogString():String{
			var msg:String = "";
			
			var date:Date = new Date();
			
			// add datetime
			msg += date.toLocaleString() + "." + leadingZeros(date.milliseconds) + " [" + level + "] ";
			
			// add category and params
			msg += "[" + category + "] " + applyParams(_message, _params);
			
			return msg;
			
			// service
			function leadingZeros(x:Number):String{
				if (x < 10){
					return "00" + x.toString();
				}
				
				if (x < 100){
					return "0" + x.toString();
				}
				
				return x.toString();
			}
			
			function applyParams(message:String, params:Array):String{
				var result:String = message;
				var numParams:int = params.length;
				
				for (var i:int = 0; i < numParams; i++){
					result = result.replace(new RegExp("\\{" + i + "\\}", "g"), params[i]);
				}
				
				return result;
			}
		}
	}
}