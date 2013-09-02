/*****************************************************
*  
*  Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.net.dvr
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.NetStreamPlayOptions;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.metadata.Metadata;
	import org.osmf.metadata.MetadataNamespaces;
	
	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class DVRCastNetStream extends NetStream
	{
		public function DVRCastNetStream(connection:NetConnection, resource:MediaResourceBase)
		{
			super(connection);
			
			recordingInfo = resource.getMetadataValue(DVRCastConstants.RECORDING_INFO_KEY) as DVRCastRecordingInfo;
		}
		
		/**
		 * @private
		 **/
		override public function play(...arguments):void
		{
			super.play(arguments[0], recordingInfo.startOffset, -1);	
		}
		
		/**
		 * @private
		 **/
		override public function play2(param:NetStreamPlayOptions):void
		{
			if (param)
			{
				param.start = recordingInfo.startOffset;
				param.len = -1;
			}	
			super.play2(param);
		}
		
		// Internals
		//
		
		private var recordingInfo:DVRCastRecordingInfo;
	}
}