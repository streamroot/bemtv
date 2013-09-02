/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
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
package org.osmf.media.pluginClasses
{
	[ExcludeClass]
	
	/**
	 * @private
	 **/
	public class VersionUtils
	{
		public static function parseVersionString(version:String):Object
		{
			var versionInfo:Array = version.split(".");
			
			var major:int = 0;
			var minor:int = 0;
			
			if (versionInfo.length >= 1)
			{
				major = parseInt(versionInfo[0]);
			}
			if (versionInfo.length >= 2)
			{
				minor = parseInt(versionInfo[1]);
				
				// Don't lose a significant digit.
				if (minor < 10)
				{
					minor = minor * 10;
				}
			}

			return {major:major, minor:minor};
		}
	}
}