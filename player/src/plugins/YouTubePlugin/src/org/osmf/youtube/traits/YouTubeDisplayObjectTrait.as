/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
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


package org.osmf.youtube.traits
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.youtube.YouTubePlayerProxy;
	import org.osmf.youtube.YouTubeUtils;

	/**
	 * YouTubeDisplayObjectTrait defines the DisplayObjectTrait interface for YouTube media.
	 *
	 * @see org.osmf.traits.DisplayObjectTrait
	 * @see flash.display.DisplayObject
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class YouTubeDisplayObjectTrait extends DisplayObjectTrait
	{
		/**
		 * Constructor.
		 *
		 * @param playerReference Reference to YouTube chromeless player.
		 */
		public function YouTubeDisplayObjectTrait(playerReference:YouTubePlayerProxy)
		{
			player = playerReference;

			// Important: the chromeless player size must be set BEFORE
			// the actual displayObject size gets set.
			// This is because the YouTube player itself handles the resizing
			// in order to keep a correct aspect ratio.
			player.setSize(player.loaderInfo.width, player.loaderInfo.height);

			if (playerReference && playerReference is DisplayObject)
			{
				player.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}

			super(player, player.loaderInfo.width, player.loaderInfo.height);
		}

		override public function get mediaWidth():Number
		{
			return YouTubeUtils.HEIGHT_MAP[player.getPlaybackQuality()] * inverseAspectRation;
		}
		
		override public function get mediaHeight():Number
		{
			return YouTubeUtils.HEIGHT_MAP[player.getPlaybackQuality()];
		}
		
		
		// Internals
		//

		/**
		 * Watch out for when the displayObject is added to stage
		 *
		 * @param event
		 */
		private function onAddedToStage(event:Event):void
		{
			player.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			displayObject.addEventListener(Event.ENTER_FRAME, onEnterFrame);							
		}

		/**
		 * Properly resize the displayObject.
		 *
		 * <p>We need to do this here to be sure the displayObject is on stage and
		 * is about to be painted, otherwise it will NOT be displayed<p>
		 *
		 * @see org.osmf.net.NetStreamDisplayObjectTrait
		 *
		 * @param event
		 */
		private function onEnterFrame(event:Event):void
		{
			newMediaSize(mediaWidth, mediaHeight);
			displayObject.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

		}

		/**
		 *
		 * Set the media size accordingly.
		 *
		 * <p>The function also handles the case when we have a layout renderer.</p>
		 *
		 * @see org.osmf.net.NetStreamDisplayObjectTrait
		 * 
		 * @param width New media width.
		 * @param height New media height.
		 */
		private function newMediaSize(width:Number, height:Number):void
		{
			if(displayObject.width == 0 &&
				displayObject.height == 0)  //If there is no layout, set as no scale.
			{
				displayObject.width = width;
				displayObject.height = height;
			}
			setMediaSize(width, height);
			inverseAspectRation = height / width;
			player.dispatchEvent(new Event(Event.RESIZE));
		}
		private var inverseAspectRation:Number = .75;
		private var player:YouTubePlayerProxy;
	}
}