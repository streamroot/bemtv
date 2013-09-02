/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 **********************************************************/

package org.osmf.player.chrome.assets
{
	import flash.display.DisplayObject;
	import flash.display.Loader;

	public class SWFAsset extends DisplayObjectAsset
	{
		public function SWFAsset(displayObject:DisplayObject)
		{
			_displayObject = displayObject;
			
			super();
		}
		
		override public function get displayObject():DisplayObject
		{
			return _displayObject;
		}
		
		private var _displayObject:DisplayObject;
	}
}