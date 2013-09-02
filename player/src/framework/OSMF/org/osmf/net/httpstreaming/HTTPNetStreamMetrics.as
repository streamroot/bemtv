/*****************************************************
*  
*  Copyright 2009 Akamai Technologies, Inc.  All Rights Reserved.
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
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved.
* 
*****************************************************/
package org.osmf.net.httpstreaming
{
	import org.osmf.net.NetStreamMetricsBase;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Metrics provider for an HTTPNetStream.
	 **/
	public class HTTPNetStreamMetrics extends NetStreamMetricsBase
	{
		/**
		 * Constructor.
		 **/
		public function HTTPNetStreamMetrics(netStream:HTTPNetStream)
		{
			super(netStream);
			
			httpNetStream = netStream;
		}

		/**
		 * The download ratio of the HTTPNetStream.  Calculated as the playback
		 * time of the last file part downloaded divided by the amount of time
		 * it took to download that whole file part, from request to completion.
		 **/
		public function get downloadRatio():Number
		{
			if (httpNetStream.qosInfo != null)
			{
				return httpNetStream.qosInfo.downloadRatio;
			}
			
			return 0;
		}
		
		/**
		 * The bitrate in kbps for the given stream index.
		 **/
		public function getBitrateForIndex(index:int):Number
		{
			return resource.streamItems[index].bitrate;
		}
		
		private var httpNetStream:HTTPNetStream;
	}
}