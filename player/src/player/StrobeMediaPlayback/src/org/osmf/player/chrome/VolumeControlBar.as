/***********************************************************
 * Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 * 
 **********************************************************/

package org.osmf.player.chrome{
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaElement;
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.widgets.AutoHideWidget;
	import org.osmf.player.chrome.widgets.MuteButton;
	import org.osmf.player.chrome.widgets.VolumeWidget;
	import org.osmf.player.chrome.widgets.Widget;
	import org.osmf.player.chrome.widgets.WidgetIDs;
	import org.osmf.traits.MediaTraitType;

	/**
	 * MobileControlBar
	 * @author johncblandii
	 */
	public class VolumeControlBar extends AutoHideWidget implements IControlBar
	{	
		// OVERRIDES
		//
		
		override public function configure(xml:XML, assetManager:AssetsManager):void
		{
			//id = WidgetIDs;
			face = AssetIDs.VOLUME_BAR_BACKDROP;
			fadeSteps = 6;
			
			layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
			layoutMetadata.verticalAlign = VerticalAlign.TOP;
			layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			super.configure(xml, assetManager);
			
			// Mute/unmute
			var muteButton:MuteButton = new MuteButton(false);
			muteButton.id = WidgetIDs.MUTE_BUTTON;
			muteButton.volumeSteps = 1;
			muteButton.layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
			muteButton.layoutMetadata.horizontalAlign = HorizontalAlign.RIGHT;
			addChildWidget(muteButton);
			
			var separator:Widget = new Widget();
			separator.face = AssetIDs.VOLUME_BAR_BUTTON_SEPARATOR;
			addChildWidget(separator);
			
			volumeWidget = new VolumeWidget();
			volumeWidget.layoutMetadata.layoutMode = LayoutMode.HORIZONTAL;
			volumeWidget.layoutMetadata.width = layoutMetadata.width;
			addChildWidget(volumeWidget);
			
			//muteButton.volumeWidget = volumeWidget;
			
			// Configure
			configureWidgets([muteButton, separator, volumeWidget]);
			
			measure();
		}
		
		override public function set media(value:MediaElement):void{
			if(value != null){
				super.media = value;
				if(volumeWidget)
					volumeWidget.media = value;
			}
		}
		
		// INTERNALS
		//
		
		private function configureWidgets(widgets:Array):void
		{
			for each( var widget:Widget in widgets)
			{
				if (widget)
				{
					widget.configure(<default/>, assetManager);					
				}
			}
		}
		
		private var volumeWidget:VolumeWidget;
		private static const _requiredTraits:Vector.<String> = new Vector.<String>;
		_requiredTraits[0] = MediaTraitType.AUDIO;
	}
}