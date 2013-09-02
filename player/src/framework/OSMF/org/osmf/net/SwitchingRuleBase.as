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
*  The Initial Developer of the Original Code is Akamai Technologies, Inc.
*  Portions created by Akamai Technologies, Inc. are Copyright (C) 2009 Akamai 
*  Technologies, Inc. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.net
{
	/**
	 * SwitchingRuleBase is a base class for classes that define multi-bitrate
	 * (MBR) switching rules.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class SwitchingRuleBase
	{
		/**
		 * Constructor.
		 * 
		 * @param metrics Provider of runtime metrics.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function SwitchingRuleBase(metrics:NetStreamMetricsBase)
		{
			super();
			
			_metrics = metrics;
		}

		/**
		 * Returns the index value in the active DynamicStreamingResource to
		 * which this switching rule thinks the bitrate should shift.  It's up
		 * to the calling function to act on this. This index will range in
		 * value from -1 to n-1,where n is the number of bitrate items available.
		 * A value of -1 means that this rule does not suggest a switch away from
		 * the current item. A value from 0 to n-1 indicates that the caller
		 * should switch to that index immediately.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function getNewIndex():int
		{
			return -1;
		}
		
		/**
		 * The provider of metrics which the rule can use to determine
		 * whether to suggest a switch.
		 **/
		protected function get metrics():NetStreamMetricsBase
		{
			return _metrics;
		}
		
		private var _metrics:NetStreamMetricsBase;
	}
}
