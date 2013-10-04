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
 * 
 **********************************************************/

package org.osmf.player.chrome
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import org.osmf.player.chrome.assets.AssetIDs;
	import org.osmf.player.chrome.assets.AssetLoader;
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.assets.BitmapResource;
	import org.osmf.player.chrome.assets.FontResource;
	import org.osmf.player.chrome.assets.SymbolResource;

	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * AssetsProvider provides the player's default chrome assets.
	 */	
	public class AssetsProvider extends EventDispatcher
	{
		// Public interface
		//
		
		public function AssetsProvider(assetsManager:AssetsManager = null)
		{
			_assetsManager = assetsManager || new AssetsManager();
			addDefaultAssets();
		}
		
		public function load():void
		{
			_assetsManager.addEventListener(Event.COMPLETE, onAssetsManagerComplete);
			_assetsManager.load();
		}
		
		public function get assetsManager():AssetsManager
		{
			return _assetsManager;
		}
		
		// Internals
		//
		
		private function addEmbeddedBitmap(id:String, symbolClass:Class):void
		{	
			var resource:BitmapResource
				= new BitmapResource
					( id
					, getQualifiedClassName(symbolClass)
					, true
					, null 
					);
			_assetsManager.addAsset(resource, new AssetLoader());
		}
		
		private function addEmbeddedSymbol(id:String, symbolClass:Class):void
		{
			
			var resource:SymbolResource
				= new SymbolResource
					( id
					, getQualifiedClassName(symbolClass)
					, true
					, null
					);
			_assetsManager.addAsset(resource, new AssetLoader());
		}
		
		private function addDefaultAssets():void
		{				
			// Default font:
			_assetsManager.addAsset
				( new FontResource
					( AssetIDs.DEFAULT_FONT
					, getQualifiedClassName(ASSET_DefaultFont)
					, true
					, AssetIDs.DEFAULT_FONT
					, 12
					, 0xDDDDDD
					)
				, new AssetLoader()
				);
			
			_assetsManager.addAsset
				( new FontResource
					( AssetIDs.DEFAULT_FONT_BOLD
						, getQualifiedClassName(ASSET_DefaultFontBold)
						, true
						, AssetIDs.DEFAULT_FONT_BOLD
						, 12
						, 0xDDDDDD
						, true
					)
					, new AssetLoader()
				);
			
			addEmbeddedSymbol(AssetIDs.CONTROL_BAR_BACKDROP, ASSET_backDrop_center);
			addEmbeddedSymbol(AssetIDs.CONTROL_BAR_BACKDROP_LEFT, ASSET_backDrop_left);
			addEmbeddedSymbol(AssetIDs.CONTROL_BAR_BACKDROP_RIGHT, ASSET_backDrop_right);
			
			// Scrub bar:
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_TRACK, ASSET_scrub_no_load);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_TRACK_LEFT, ASSET_scrub_left);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_TRACK_RIGHT, ASSET_scrub_right);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_LOADED_TRACK, ASSET_scrub_loaded);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_LOADED_TRACK_END, ASSET_scrub_loaded_end);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_PLAYED_TRACK, ASSET_scrub_loaded_played);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_PLAYED_TRACK_SEEKING, ASSET_scrub_loaded_played_seeking);
			
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_DVR_LIVE_TRACK, ASSET_ScrubDvrLive);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_DVR_LIVE_INACTIVE_TRACK, ASSET_ScrubDvrLiveInactive);	
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_LIVE_ONLY_TRACK, ASSET_ScrubLive);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_LIVE_ONLY_INACTIVE_TRACK, ASSET_ScrubLiveInactive);
			
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_SCRUBBER_NORMAL, ASSET_scrub_tab);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_SCRUBBER_DOWN, ASSET_scrub_tab);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_SCRUBBER_OVER, ASSET_scrub_tab);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_SCRUBBER_OVER, ASSET_scrub_tab);
			addEmbeddedSymbol(AssetIDs.SCRUB_BAR_TIME_HINT, ASSET_time_hint);
						
			// Play button:
			addEmbeddedSymbol(AssetIDs.PLAY_BUTTON_NORMAL, ASSET_play_normal);
			addEmbeddedSymbol(AssetIDs.PLAY_BUTTON_DOWN, ASSET_play_selected);
			addEmbeddedSymbol(AssetIDs.PLAY_BUTTON_OVER, ASSET_play_over);
			
			// Play overlay:
			addEmbeddedSymbol(AssetIDs.PLAY_BUTTON_OVERLAY_NORMAL, ASSET_play_overlayed_normal);
			addEmbeddedSymbol(AssetIDs.PLAY_BUTTON_OVERLAY_DOWN, ASSET_play_overlayed_normal);
			addEmbeddedSymbol(AssetIDs.PLAY_BUTTON_OVERLAY_OVER, ASSET_play_overlayed_over);
			
			// Pause button:
			addEmbeddedSymbol(AssetIDs.PAUSE_BUTTON_NORMAL, ASSET_pause_normal);
			addEmbeddedSymbol(AssetIDs.PAUSE_BUTTON_DOWN, ASSET_pause_selected);
			addEmbeddedSymbol(AssetIDs.PAUSE_BUTTON_OVER, ASSET_pause_over);			
			
			// Mute:
			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_NORMAL, ASSET_volume_low_normal);
			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_DOWN, ASSET_volume_low_selected);
			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_OVER, ASSET_volume_low_over);			

			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_LOW_NORMAL, ASSET_volume_low_normal);
			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_LOW_DOWN, ASSET_volume_low_selected);
			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_LOW_OVER, ASSET_volume_low_over);			

			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_MED_NORMAL, ASSET_volume_med_normal);
			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_MED_DOWN, ASSET_volume_med_selected);
			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_MED_OVER, ASSET_volume_med_over);			

			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_HIGH_NORMAL, ASSET_volume_high_normal);
			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_HIGH_DOWN, ASSET_volume_high_selected);
			addEmbeddedSymbol(AssetIDs.VOLUME_BUTTON_HIGH_OVER, ASSET_volume_high_over);			

			// Unmute:
			addEmbeddedSymbol(AssetIDs.UNMUTE_BUTTON_NORMAL, ASSET_volume_mute_normal);
			addEmbeddedSymbol(AssetIDs.UNMUTE_BUTTON_DOWN, ASSET_volume_mute_selected);
			addEmbeddedSymbol(AssetIDs.UNMUTE_BUTTON_OVER, ASSET_volume_mute_over);
			
			// Volume slider:
			addEmbeddedSymbol(AssetIDs.VOLUME_BAR_BACKDROP, ASSET_volume_back);
			addEmbeddedSymbol(AssetIDs.VOLUME_BAR_TRACK, ASSET_volume_scrub);
			addEmbeddedSymbol(AssetIDs.VOLUME_BAR_TRACK_END, ASSET_volume_scrub_bottom);
			addEmbeddedSymbol(AssetIDs.VOLUME_BAR_SLIDER_NORMAL, ASSET_volume_slider);
			addEmbeddedSymbol(AssetIDs.VOLUME_BAR_SLIDER_DOWN, ASSET_volume_slider);
			addEmbeddedSymbol(AssetIDs.VOLUME_BAR_SLIDER_OVER, ASSET_volume_slider);
			
			// Fullscreen enter:
			addEmbeddedSymbol(AssetIDs.FULL_SCREEN_ENTER_NORMAL, ASSET_fullscreen_on_normal);
			addEmbeddedSymbol(AssetIDs.FULL_SCREEN_ENTER_DOWN, ASSET_fullscreen_on_selected);
			addEmbeddedSymbol(AssetIDs.FULL_SCREEN_ENTER_OVER, ASSET_fullscreen_on_over);
			
			// Fullscreen leave:
			addEmbeddedSymbol(AssetIDs.FULL_SCREEN_LEAVE_NORMAL, ASSET_fullscreen_off_normal);
			addEmbeddedSymbol(AssetIDs.FULL_SCREEN_LEAVE_DOWN, ASSET_fullscreen_off_selected);
			addEmbeddedSymbol(AssetIDs.FULL_SCREEN_LEAVE_OVER, ASSET_fullscreen_off_over);
			
			// Authentication dialog:
			addEmbeddedSymbol(AssetIDs.AUTH_BACKDROP, ASSET_auth_backdrop);
			addEmbeddedSymbol(AssetIDs.AUTH_SUBMIT_BUTTON_NORMAL, ASSET_button_normal);
			addEmbeddedSymbol(AssetIDs.AUTH_SUBMIT_BUTTON_DOWN, ASSET_button_selected);
			addEmbeddedSymbol(AssetIDs.AUTH_SUBMIT_BUTTON_OVER, ASSET_button_over);
			addEmbeddedSymbol(AssetIDs.AUTH_CANCEL_BUTTON_NORMAL, ASSET_close_normal);
			addEmbeddedSymbol(AssetIDs.AUTH_CANCEL_BUTTON_OVER, ASSET_close_over);
			addEmbeddedSymbol(AssetIDs.AUTH_CANCEL_BUTTON_DOWN, ASSET_close_selected);
			addEmbeddedSymbol(AssetIDs.AUTH_WARNING, ASSET_warning);
			
			// Previous button:
			addEmbeddedSymbol(AssetIDs.PREVIOUS_BUTTON_NORMAL, ASSET_previous_normal);
			addEmbeddedSymbol(AssetIDs.PREVIOUS_BUTTON_DOWN, ASSET_previous_selected);
			addEmbeddedSymbol(AssetIDs.PREVIOUS_BUTTON_OVER, ASSET_previous_rollover);
			addEmbeddedSymbol(AssetIDs.PREVIOUS_BUTTON_DISABLED, ASSET_previous_disabled)
			
			// Next button:
			addEmbeddedSymbol(AssetIDs.NEXT_BUTTON_NORMAL, ASSET_next_normal);
			addEmbeddedSymbol(AssetIDs.NEXT_BUTTON_DOWN, ASSET_next_selected);
			addEmbeddedSymbol(AssetIDs.NEXT_BUTTON_OVER, ASSET_next_rollover);
			addEmbeddedSymbol(AssetIDs.NEXT_BUTTON_DISABLED, ASSET_next_disabled)
			
			// HD indicator:
			addEmbeddedSymbol(AssetIDs.HD_ON, ASSET_hd_on);
			addEmbeddedSymbol(AssetIDs.HD_OFF, ASSET_hd_off);
			
			// Buffering overlay:
			addEmbeddedSymbol(AssetIDs.BUFFERING_OVERLAY, ASSET_BufferingOverlay);
		}
		
		private function onAssetsManagerComplete(event:Event):void
		{
			// Redispatch the completion event:
			dispatchEvent(event.clone());	
		}
		
		private var _assetsManager:AssetsManager;
	}
}