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
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	
	public class PauseButton extends PlayableButton
	{

		public function PauseButton()
		{
			super();
			
			upFace = AssetIDs.PAUSE_BUTTON_NORMAL;
			downFace = AssetIDs.PAUSE_BUTTON_DOWN;
			overFace = AssetIDs.PAUSE_BUTTON_OVER;
		}
		// Overrides
		//

		
		override protected function onMouseClick(event:MouseEvent):void
		{
			var playable:PlayTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
			if ( playable.canPause)
			{
				playable.pause();
			}
			else
			{
				playable.stop();
			}
			event.stopImmediatePropagation();
		}
		
		override protected function visibilityDeterminingEventHandler(event:Event = null):void
		{
			visible = (playable && playable.playState == PlayState.PLAYING) 
			if (media && media.metadata)
			{
				visible ||= media.metadata.getValue("Advertisement") != null;
			}	
		}
	}
}