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
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.player.chrome.assets.AssetIDs;
	
	public class BackButton extends ButtonWidget
	{
		public function BackButton()
		{
			super();
			
			upFace = AssetIDs.BACK_BUTTON_NORMAL
			downFace = AssetIDs.BACK_BUTTON_DOWN;
			overFace = AssetIDs.BACK_BUTTON_OVER;
		}
	
		// Overrides
		//
		
		override protected function onMouseClick(event:MouseEvent):void
		{
			stage.displayState = StageDisplayState.NORMAL;
			event.stopImmediatePropagation();
		}
	}
}