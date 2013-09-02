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
package org.osmf.utils
{
	import flash.net.URLLoader;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;

	[ExcludeClass]
	
	/**
	 * @private
	 **/
	public class HTTPLoadTrait extends LoadTrait
	{
		public function HTTPLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(loader, resource);
		}

		/**
		 * The URLLoader for the HTTP request.
		 */
		public function get urlLoader():URLLoader
		{
			return _urlLoader;
		}
		
		public function set urlLoader(value:URLLoader):void
		{
			_urlLoader = value;
		}
		
		private var _urlLoader:URLLoader;
	}
}