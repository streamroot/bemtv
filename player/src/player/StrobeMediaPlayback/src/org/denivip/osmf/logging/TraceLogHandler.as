package org.denivip.osmf.logging
{
	public class TraceLogHandler extends LogHandler
	{
		public function TraceLogHandler(){
			super();
		}
		
		override public function handleMessage(logMessage:LogMessage):void{
			trace(logMessage.toString());
		}
	}
}