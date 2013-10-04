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

package org.osmf.player.chrome.widgets
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	
	public class ButtonHighlight extends Sprite
	{
		public function ButtonHighlight(assetManager:AssetsManager)
		{
			super();
			var highlight:DisplayObject = assetManager.getDisplayObject(AssetIDs.BUTTON_HIGHLIGHT);
			if(highlight) addChild(highlight);
		}
	}
}