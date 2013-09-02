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
package org.osmf.media
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.events.MediaElementChangeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	
	/**
	 * MediaPlayerSprite provides MediaPlayer, MediaContainer, and MediaFactory
	 * capabilities all in one Sprite-based class.  It also provides convenience
	 * methods to generate MediaElements from a resource and set the ScaleMode.
	 * 
	 *  @includeExample MediaPlayerSpriteExample.as -noswf
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0	 	 
	 **/
	public class MediaPlayerSprite extends Sprite
	{	
		/**
		 * Constructor.
		 * 
		 * @param mediaPlayer A custom MediaPlayer can be provided. If null, defaults to new MediaPlayer.
		 * @param mediaContainer A custom MediaContainer can be provided. If null defaults to a new MediaContainer.
		 * @param mediaFactory A custom MediaFactory can be provided. If null defaults to a new DefaultMediaFactory.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0	 	 
		 **/
		public function MediaPlayerSprite(mediaPlayer:MediaPlayer = null, mediaContainer:MediaContainer = null, mediaFactory:MediaFactory = null)
		{
			_mediaPlayer = mediaPlayer ? mediaPlayer : new MediaPlayer();
			_mediaFactory = mediaFactory;
			_mediaContainer = mediaContainer ? mediaContainer : new MediaContainer();
			_mediaPlayer.addEventListener(MediaElementChangeEvent.MEDIA_ELEMENT_CHANGE, onMediaElementChange);
			addChild(_mediaContainer);
			
			if (_mediaPlayer.media != null)
			{
				media = _mediaPlayer.media;
			}			
		}
		
		/**
		 * Source MediaElement presented by this MediaPlayerSprite.
		 * 
		 * <p>Setting the element will set it as the media on the mediaPlayer, 
		 * and add it to the media container.  Setting this property to null will remove it
		 * both from the player and container.  Existing in properties, such as layout will be
		 * preserved on media.</p>
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get media():MediaElement
		{
			return _media;
		}

		public function set media(value:MediaElement):void
		{
			if (_media != value)
			{
				if (_media && _mediaContainer.containsMediaElement(_media))
				{
					_mediaContainer.removeMediaElement(_media);
				}
				_media = value;				
				if (_media && _media.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) == null)
				{
					var layout:LayoutMetadata = new LayoutMetadata();
					layout.scaleMode = _scaleMode;
					layout.verticalAlign = VerticalAlign.MIDDLE;
					layout.horizontalAlign = HorizontalAlign.CENTER;
					layout.percentWidth = 100;
					layout.percentHeight = 100;
					_media.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
				}				
				_mediaPlayer.media = value;
				if (value && !_mediaContainer.containsMediaElement(value) )
				{
					_mediaContainer.addMediaElement(value);
				}				
			}		
		}
					
		/**
		 * The resource corresponding to the media element that is currently
		 * being presented by this MediaPlayerSprite.
		 * 
		 * <p>When set, this property uses the MediaFactory to generate a new
		 * MediaElement, and sets it as the MediaElement on this MediaPlayerSprite.
		 * If null, it will remove the existing MediaElement and resource from
		 * the player and container.  If the MediaFactory can't create a
		 * MediaElement from the given resource, it will set the media and 
		 * to null.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get resource():MediaResourceBase
		{
			return _media ? _media.resource : null;
		}

		public function set resource(value:MediaResourceBase):void
		{
			media = value ? mediaFactory.createMediaElement(value) : null;			
		}
			
		/**
		 * The MediaPlayer that controls this media element.
		 * 
		 * <p>Defaults to an instance of MediaPlayer. When an element is set
		 * directly on the MediaPlayer, the media element is propagated to
		 * the MediaPlayerSprite, and the MediaContainer.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get mediaPlayer():MediaPlayer
		{
			return _mediaPlayer;
		}
		
		/**
		 * The MediaContainer that is used with this class.
		 * 
		 * <p>Defaults to an instance of MediaContainer.  Any media elements
		 * added or removed through addMediaElement() or removeMediaElement()
		 * are not set on the MediaPlayer.  In order to set the MediaElement,
		 * use the setter on the MediaPlayerSprite.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get mediaContainer():MediaContainer
		{
			return _mediaContainer;
		}
		
		/**
		 * The MediaFactory that is used with this class.
		 * 
		 * <p>Defaults to an instance of DefaultMediaFactory.  Plugins should
		 * be loaded through this media factory.  Media elements created
		 * directly through this factory aren't added to the MediaPlayer or
		 * MediaContainer.  To associate a new media element with the
		 * MediaPlayerSprite, set the media property on this class.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function get mediaFactory():MediaFactory
		{
			_mediaFactory = _mediaFactory ? _mediaFactory : new DefaultMediaFactory();
			return _mediaFactory;
		}
			
		/**
		 * Defines how content within the MediaPlayerSprite will be laid out.
		 * 
		 * <p>The default value is <code>letterbox</code>.</p>
		 * 
		 * <p>Note that by default the MediaContainer sets the layout to be 100%
		 * width, 100% height, and centered.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 			
		public function get scaleMode():String
		{
			return _scaleMode;
		}
		
		public function set scaleMode(value:String):void
		{
			_scaleMode = value;
			if (_media)
			{
				var layout:LayoutMetadata = _media.getMetadata(LayoutMetadata.LAYOUT_NAMESPACE) as LayoutMetadata;
				layout.scaleMode = value;
			}		
		}
		
		/**
		 * @private
		 */ 
		override public function set width(value:Number):void
		{
			_mediaContainer.width = value;
		}
		
		/**
		 * @private
		 */ 
		override public function set height(value:Number):void
		{	
			_mediaContainer.height = value;			
			
		}
		
		/**
		 * @private
		 */ 
		override public function get width():Number
		{
			return _mediaContainer.width;
		}
		
		/**
		 * @private
		 */ 
		override public function get height():Number
		{
			return _mediaContainer.height;
		}
		
		private function onMediaElementChange(event:MediaElementChangeEvent):void
		{
			media = _mediaPlayer.media;
		}
		
		private var _scaleMode:String = ScaleMode.LETTERBOX;
		private var _media:MediaElement;
		private var _mediaPlayer:MediaPlayer;
		private var _mediaFactory:MediaFactory;
		private var _mediaContainer:MediaContainer;			
	}
}