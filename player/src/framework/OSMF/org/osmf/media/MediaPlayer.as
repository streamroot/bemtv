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
	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.events.*;
	import org.osmf.net.StreamingItem;
	import org.osmf.traits.*;
	import org.osmf.utils.OSMFStrings;
	 	 
	/**
	 * Dispatched when the MediaPlayer's state has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="mediaPlayerStateChange", type="org.osmf.events.MediaPlayerStateChangeEvent")]
	
    /**
	 * Dispatched when the <code>currentTime</code> property of the media has changed.
	 * This value is updated at the interval set by 
	 * the MediaPlayer's <code>currentTimeUpdateInterval</code> property.
	 *
	 * @eventType org.osmf.events.TimeEvent.CURRENT_TIME_CHANGE
	 * 
	 * 	@langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 **/
    [Event(name="currentTimeChange",type="org.osmf.events.TimeEvent")]  
    
	/**
	 * Dispatched when the value of bytesLoaded has changed.
	 *
	 * @eventType org.osmf.events.LoadEvent
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="bytesLoadedChange",type="org.osmf.events.LoadEvent")]

    /**
	 * Dispatched when the <code>canPlay</code> property has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */    
	[Event(name="canPlayChange", type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
	
	/**
	 * Dispatched when the <code>canBuffer</code> property has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */    
	[Event(name="canBufferChange", type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
			
	/**
	 * Dispatched when the <code>canSeek</code> property has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="canSeekChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
	
	/**
	 * Dispatched when the <code>isDynamicStream</code> property has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="isDynamicStreamChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
	
	/**
	 * Dispatched when the <code>hasAlternativeAudio</code> property has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerCapabilityChangeEvent.HAS_ALTERNATIVE_AUDIO_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.6
	 */
	[Event(name="hasAlternativeAudio",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]

	/**
	 * Dispatched when the <code>temporal</code> property has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	 
	[Event(name="temporalChange", type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
	
	/**
	 * Dispatched when the <code>hasAudio</code> property has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="hasAudioChange", type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
			
	/**
	 * Dispatched when the <code>canLoad</code> property has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="canLoadChange", type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
	
	/**
	 * Dispatched when the <code>hasDRM</code> property has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerCapabilityChangeEvent.HAS_DRM_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="hasDRMChange", type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
		
	
	/**
	 * Dispatched when the <code>hasDisplayObjectChange</code> property has changed.
	 * 
	 * @eventType org.osmf.events.MediaPlayerCapabilityChangeEvent.HAS_DISPLAY_OBJECT_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="hasDisplayObjectChange", type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
		
	/**
	 * Dispatched when an error which impacts the operation of the media
	 * player occurs.
	 *
	 * @eventType org.osmf.events.MediaErrorEvent.MEDIA_ERROR
	 * 
	 * 	@langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 **/
	[Event(name="mediaError",type="org.osmf.events.MediaErrorEvent")]

	/**
	 * MediaPlayer is the controller class used for interaction with all media types.
	 * <p>It is a high level class that shields the developer from the low level details of the
	 * media framework. The MediaPlayer class also provides some convenient features such as loop, 
	 * auto-play and auto-rewind.</p>
	 *  
	 * <p>The MediaPlayer can play back all media types supported by the Open Source Media Framework, 
	 * including media compositions.</p>
	 * 
	 *  @includeExample MediaPlayerExample.as -noswf
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaPlayer extends TraitEventDispatcher
	{
		/**
		 * Constructor.
		 * 
         * @param media Source MediaElement to be controlled by this MediaPlayer.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MediaPlayer(media:MediaElement=null)
		{
			super();
			
			_state = MediaPlayerState.UNINITIALIZED;
			
			this.media = media;
			
			_currentTimeTimer.addEventListener(TimerEvent.TIMER, onCurrentTimeTimer, false, 0, true);			
			_bytesLoadedTimer.addEventListener(TimerEvent.TIMER, onBytesLoadedTimer, false, 0, true);
		}

		/**
		 * Source MediaElement controlled by this MediaPlayer.  Setting the media will attempt to load 
		 * media that is loadable, that isn't loading or loaded.  It will automatically unload media when
		 * the property changes to a new MediaElement or null.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		override public function set media(value:MediaElement):void
		{			
			if (value != media)
			{
				var traitType:String;
				
				mediaAtEnd = false;
				
				if (media != null)
				{
					// If we're in the middle of an auto-rewind, it will be cancelled
					// (and we should update our state so as not to break looping, see
					// FM-1092).
					inExecuteAutoRewind = false;
					
					if (playing)
					{
						// Stop, but don't auto-rewind.
						(getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).stop();
					}
					if (canLoad)
					{	 
						var loadTrait:LoadTrait = media.getTrait(MediaTraitType.LOAD) as LoadTrait;
						if (loadTrait.loadState == LoadState.READY) // Do a courtesy unload
						{							
							loadTrait.unload();
						}
					}	
					setState(MediaPlayerState.UNINITIALIZED);
					
					if (media) //sometimes media is null here due to unload nulling the element.
					{
						media.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
						media.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
						media.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
						for each (traitType in media.traitTypes)
						{
							updateTraitListeners(traitType, false);
						}
					}								
				}
				super.media = value;
				if (media != null)
				{
					media.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);					
					media.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
					media.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);					

					// If the media cannnot be loaded, then the MediaPlayer's state
					// should represent the media as already ready.
					if (media.hasTrait(MediaTraitType.LOAD) == false)
					{
						processReadyState();
					}

					for each (traitType  in media.traitTypes)
					{
						updateTraitListeners(traitType, true);
					}
				}
				dispatchEvent(new MediaElementChangeEvent(MediaElementChangeEvent.MEDIA_ELEMENT_CHANGE));				
			}
		}
		
            
        /**
		 * Indicates whether media is returned to the beginning after playback completes. 
		 * 
		 * If <code>true</code>, when playback completes, the player displays the first 
		 * frame of the media. If <code>false</code>, when playback completes, the last 
		 * frame is displayed. The default is <code>true</code>. The <code>autoRewind</code> 
		 * property is ignored if the <code>loop</code> property is set to <code>true</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set autoRewind(value:Boolean):void
		{
			_autoRewind = value;				
		}
		
        public function get autoRewind():Boolean
        {
        	return _autoRewind;
        }

        /**
		 * Indicates whether the MediaPlayer starts playing the media as soon as its
		 * load operation has successfully completed.
		 * The default is <code>true</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set autoPlay(value:Boolean):void
		{
			_autoPlay = value;				
		}
		
        public function get autoPlay():Boolean
        {
        	return _autoPlay;
        }

         /**
         * Indicates whether the media should play again after playback has completed.
         * The <code>loop</code> property takes precedence over the <code>autoRewind</code> property,
         * so if <code>loop</code> is set to <code>true</code>, the <code>autoRewind</code> property
         * is ignored.
         * <p>The default is <code>false</code>.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set loop(value:Boolean):void
		{
			_loop = value;
		}
		
        public function get loop():Boolean
        {
        	return _loop;
        }

        /**
		 * Interval between the dispatch of change events for the current time
		 * in milliseconds. 
         * <p>The default is 250 milliseconds.
         * A non-positive value disables the dispatch of the change events.</p>
 		 * 
		 * @see org.osmf.events.#event:TimeEvent
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set currentTimeUpdateInterval(value:Number):void
		{
			if (_currentTimeUpdateInterval != value)
			{
				_currentTimeUpdateInterval = value;
				if (isNaN(_currentTimeUpdateInterval) || _currentTimeUpdateInterval <= 0)
				{
					_currentTimeTimer.stop();	
				}
				else
				{				
					_currentTimeTimer.delay = _currentTimeUpdateInterval;		
					if (temporal)
					{
						_currentTimeTimer.start();
					}			
				}					
			}			
		}
		
        public function get currentTimeUpdateInterval():Number
        {
        	return _currentTimeUpdateInterval;
        }
        
        /**
		 * Interval between the dispatch of change events for the bytesLoaded property. 
         * <p>The default is 250 milliseconds.
         * A non-positive value disables the dispatch of the change events.</p>
		 * 
		 * @see org.osmf.events.#event:LoadEvent
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
        public function set bytesLoadedUpdateInterval(value:Number):void
        {
        	if (_bytesLoadedUpdateInterval != value)
        	{
        		_bytesLoadedUpdateInterval = value;
        		
				if (isNaN(_bytesLoadedUpdateInterval) || _bytesLoadedUpdateInterval <= 0)
				{
					_bytesLoadedTimer.stop();	
				}
				else
				{				
					_bytesLoadedTimer.delay = _bytesLoadedUpdateInterval;		
					if (canLoad)
					{
						_bytesLoadedTimer.start();
					}			
				}					
        	}
        }
        
        public function get bytesLoadedUpdateInterval():Number
        {
        	return _bytesLoadedUpdateInterval;
        }

		/**
         *  The current state of the media.  See MediaPlayerState for available values.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion OSMF 1.0
         */      
        public function get state():String
        {
        	return _state;
        }               
 		
		/**
		 *  Indicates whether the media can be played.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get canPlay():Boolean
		{
			return _canPlay;
		}

		/**
		 *  Indicates whether the media can be paused.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get canPause():Boolean
		{
			return canPlay ? (getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).canPause : false;
		}
				
		/**
		 * Indicates whether the media is seekable.
		 * Seekable media can jump to a specified time.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get canSeek():Boolean
		{
			return _canSeek;
		}
		
		/**
		 * Indicates whether the media is temporal.
		 * Temporal media supports a duration and a currentTime within that duration.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get temporal():Boolean
		{
			return _temporal;
		}
		/**
		 *  Indicates whether the media has audio.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get hasAudio():Boolean
		{
			return _hasAudio;
		}
						
		/**
		 * Indicates whether the media consists of a dynamic stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get isDynamicStream():Boolean
		{
			return _isDynamicStream;
		}
		
		/**
		 * Indicates whether the media has alternative audio streams or not.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */	
		public function get hasAlternativeAudio():Boolean
		{
			return _hasAlternativeAudio;
		}
				
		/**
		 *  Indicates whether the media can be loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get canLoad():Boolean
		{
			return _canLoad;
		}
		
		/**
		 * Indicates whether the media can buffer.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get canBuffer():Boolean
		{
			return _canBuffer;
		}
						
		/**
		 *  Return if the the media element has the DRMTrait.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get hasDRM():Boolean
		{
			return _hasDRM;
		}	
		
		/**
		 * Volume of the media.
		 * Ranges from 0 (silent) to 1 (full volume). 
		 * <p>If the MediaElement doesn't have audio, then the volume will be set to
		 * this value as soon as the MediaElement has audio.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    public function get volume():Number
	    {	
	    	return hasAudio ? AudioTrait(getTraitOrThrow(MediaTraitType.AUDIO)).volume : mediaPlayerVolume;	    		    
	    }		   
	    
	    public function set volume(value:Number):void
	    {
	    	var doDispatchEvent:Boolean = false;
	    	
	    	if (hasAudio)
	    	{
	    		(getTraitOrThrow(MediaTraitType.AUDIO) as AudioTrait).volume = value;
	    	}
	    	else if (value != mediaPlayerVolume)
	    	{
	    		doDispatchEvent = true;
	    	}

    		mediaPlayerVolume = value;
    		mediaPlayerVolumeSet = true;

     		if (doDispatchEvent)
    		{
    			dispatchEvent(new AudioEvent(AudioEvent.VOLUME_CHANGE, false, false, false, value));
    		}
	    }
		
		/**
		 * Indicates whether the media is currently muted.
		 * <p>If the MediaElement doesn't have audio, then the muted state will be set to
		 * this value as soon as the MediaElement has audio.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */				
	    public function get muted():Boolean
	    {
	    	return hasAudio ? AudioTrait(getTraitOrThrow(MediaTraitType.AUDIO)).muted : mediaPlayerMuted;	    	   
	    }
	    
	    public function set muted(value:Boolean):void
	    {
	    	var doDispatchEvent:Boolean = false;
	    	
	    	if (hasAudio)
	    	{
	    		(getTraitOrThrow(MediaTraitType.AUDIO) as AudioTrait).muted = value;
	    	}
	    	else if (value != mediaPlayerMuted)
	    	{
	    		doDispatchEvent = true;
	    	}

    		mediaPlayerMuted = value;
    		mediaPlayerMutedSet = true;
    		
    		if (doDispatchEvent)
    		{
    			dispatchEvent(new AudioEvent(AudioEvent.MUTED_CHANGE, false, false, value));
    		}
	    }
	 	 
		/**
		 * Pan property of the media.
		 * Ranges from -1 (full pan left) to 1 (full pan right).
		 * <p>If the MediaElement doesn't have audio, then the pan property will be set to
		 * this value as soon as the MediaElement has audio.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    public function get audioPan():Number
	    {
	    	return hasAudio ? AudioTrait(getTraitOrThrow(MediaTraitType.AUDIO)).pan : mediaPlayerAudioPan;	    		
	    }
	    
	    public function set audioPan(value:Number):void
	    {
	    	var doDispatchEvent:Boolean = false;
	    	
	    	if (hasAudio)
	    	{
	    		(getTraitOrThrow(MediaTraitType.AUDIO) as AudioTrait).pan = value;
	    	}
	    	else if (value != mediaPlayerAudioPan)
	    	{
	    		doDispatchEvent = true;
	    	}

    		mediaPlayerAudioPan = value;
    		mediaPlayerAudioPanSet = true;
    		
    		if (doDispatchEvent)
    		{
    			dispatchEvent(new AudioEvent(AudioEvent.PAN_CHANGE, false, false, false, NaN, value));
    		}
		}
			
		/**
		 * Indicates whether the media is currently paused.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get paused():Boolean
	    {
	    	return canPlay ? (getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).playState == PlayState.PAUSED : false;	    		    
	    }
	    
		/**
	    * Pauses the media, if it is not already paused.
	    * @throws IllegalOperationError if the media cannot be paused.
	    *  
	    *  @langversion 3.0
	    *  @playerversion Flash 10
	    *  @playerversion AIR 1.5
	    *  @productversion OSMF 1.0
	    */
	    public function pause():void
	    {
	    	(getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).pause();	    		
	    }
	
		/**
		 * Indicates whether the media is currently playing.
		 * <p>The MediaElement must be playable to support this property.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */					
	    public function get playing():Boolean
	    {
	    	return canPlay ? (getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).playState == PlayState.PLAYING : false;	    		
	    }
	    
	    /**
	    * Plays the media, if it is not already playing.
		* To use the play() method, MediaPlayer.canPlay must be true.
		* You must listen for the mediaPlayerStateChange event, and only
		* call play() (or enable the UI play button) when the state is READY.
		* 
	    * @throws IllegalOperationError if the media cannot be played.
	    *  
	    *  @langversion 3.0
	    *  @playerversion Flash 10
	    *  @playerversion AIR 1.5
	    *  @productversion OSMF 1.0
	    */
	    public function play():void
	    {
	    	// Bug FM-347 - the media player should auto-rewind once the
	    	// playhead is at the end, and play() is called.
	    	if (canPlay && 
	    		canSeek &&
	    		canSeekTo(0) &&
	    		mediaAtEnd)
	    	{
	    		executeAutoRewind(true);
	    	}
	    	else
	    	{
	    	   	(getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).play();	  
	    	}	    	  	
	    }
		
		/**
		 * Indicates whether the media is currently seeking.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */			
	    public function get seeking():Boolean
	    {
	    	return canSeek ? (getTraitOrThrow(MediaTraitType.SEEK) as SeekTrait).seeking : false;
	    }
	    
	    /**
	     * Instructs the playhead to jump to the specified time.
	     * <p>If <code>time</code> is NaN or negative, does not attempt to seek.</p>
	     * @param time Time to seek to in seconds.
	     * @throws IllegalOperationError if the media cannot be seeked.
	     *  
	     *  @langversion 3.0
	     *  @playerversion Flash 10
	     *  @playerversion AIR 1.5
	     *  @productversion OSMF 1.0
	     */	    
	    public function seek(time:Number):void
	    {
	    	inSeek = true;
	    	(getTraitOrThrow(MediaTraitType.SEEK) as SeekTrait).seek(time);
	    	inSeek = false;	    				
	    }
	    
		/**
		 * Indicates whether the media is capable of seeking to the
		 * specified time.
		 *  
		 * @param time Time to seek to in seconds.
		 * @return Returns <code>true</code> if the media can seek to the specified time.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
	    public function canSeekTo(time:Number):Boolean
	    {
	    	return canSeek ? (getTraitOrThrow(MediaTraitType.SEEK) as SeekTrait).canSeekTo(time) : false;
	    }
	    
	    /**
	     * Immediately halts playback and returns the playhead to the beginning
	     * of the media file.
	     * 
	     * @throws IllegalOperationError If the media cannot be played (and therefore
	     * cannot be stopped).
	     *  
	     *  @langversion 3.0
	     *  @playerversion Flash 10
	     *  @playerversion AIR 1.5
	     *  @productversion OSMF 1.0
	     */
	    public function stop():void
	    {
	    	(getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).stop();

			if (canSeek)
			{
				executeAutoRewind(false);
			}
	    }
	
		/**
		 * Intrinsic width of the media, in pixels.
		 * The intrinsic width is the width of the media before any processing has been applied.
		 * The default if no DisplayObjectTrait is present, is NaN.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    public function get mediaWidth():Number
	    {
	    	return _hasDisplayObject ? (getTraitOrThrow(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait).mediaWidth : NaN;
	    }
		   
		/**
		 * Intrinsic height of the media, in pixels.
		 * The intrinsic height is the height of the media before any processing has been applied.
		 * The default if no DisplayObjectTrait is present, is NaN.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get mediaHeight():Number
	    {
	    	return _hasDisplayObject ? (getTraitOrThrow(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait).mediaHeight : NaN;
	    }
	    
	    /**
		 * Indicates whether or not the media will automatically switch between
		 * dynamic streams.  If in manual mode the <code>switchDynamicStreamIndex</code>
		 * method can be used to manually switch to a specific stream.
		 * 
		 * <p>The default is true.</p>
		 *		 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get autoDynamicStreamSwitch():Boolean
		{
			return isDynamicStream ? (getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).autoSwitch : mediaPlayerAutoDynamicStreamSwitch;
		}
		
		public function set autoDynamicStreamSwitch(value:Boolean):void
		{
			var doDispatchEvent:Boolean = false;
			
			if (isDynamicStream)
			{
				(getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).autoSwitch = value;
			}
						
			else if (value != mediaPlayerAutoDynamicStreamSwitch)
			{
				doDispatchEvent = true;
			}
			
			mediaPlayerAutoDynamicStreamSwitch = value;
			mediaPlayerAutoDynamicStreamSwitchSet = true;
			
			if (doDispatchEvent)
			{
				dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.AUTO_SWITCH_CHANGE, false, false, dynamicStreamSwitching, mediaPlayerAutoDynamicStreamSwitch));
			}			
		}
		
		/**
		 * The index of the dynamic stream currently rendering.  Uses a zero-based index.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get currentDynamicStreamIndex():int
		{
			return isDynamicStream ? (getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).currentIndex : 0; 
		}

		/**
		 * The total number of dynamic stream indices.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get numDynamicStreams():int
		{
			return isDynamicStream ? (getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).numDynamicStreams : 0; 
		}
		
		/**
		 * Gets the associated bitrate, in kilobytes for the specified dynamic stream index.
		 * 
		 * @throws RangeError If the specified dynamic stream index is less than zero or
		 * greater than the highest dynamic stream index available.
		 * @throws IllegalOperationError If the media is not a dynamic stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function getBitrateForDynamicStreamIndex(index:int):Number
		{
			return (getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).getBitrateForIndex(index);
		}
		
		/**
		 * The index of the alternative audio stream currently in use. Returns the 
		 * 0-based index of the selected stream, or <code>-1</code> if no stream 
		 * is selected.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public function get currentAlternativeAudioStreamIndex():int
		{
			return hasAlternativeAudio ? (getTraitOrThrow(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait).currentIndex : -1; 
		}
		
		/**
		 * Returns the total number of alternative audio streams or <code>0</code>
		 * if there are no alternative audio streams present.
		 * 
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public function get numAlternativeAudioStreams():int
		{
			return hasAlternativeAudio ? (getTraitOrThrow(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait).numAlternativeAudioStreams : 0; 
		}
		
		/**
		 * Obtains the alternative audio stream corresponding to the specified 
		 * (0-based) index. Returns <code>null</code> if the index is <code>-1</code>.
		 * 
		 * @throws  RangeError if the specified alternative audio stream index is less 
		 * 			than <code>-1</code> or greater than the highest alternative audio
		 * 			index available.
		 * @throws  IllegalOperationError if the currently loaded media does not have
		 * 			any associated alternative audio streams.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */ 
		public function getAlternativeAudioItemAt(index:int):StreamingItem
		{
			return (getTraitOrThrow(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait).getItemForIndex(index);
		}

		/**
		 * The maximum allowed dynamic stream index. This can be set at run-time to 
		 * provide a ceiling for the switching profile, for example, to keep from
		 * switching up to a higher quality stream when the current video is too small
		 * handle a higher quality stream.
		 * 
		 * @throws RangeError If the specified dynamic stream index is less than zero or
		 * greater than the highest dynamic stream index available.
		 * @throws IllegalOperationError If the media is not a dynamic stream.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get maxAllowedDynamicStreamIndex():int
		{
			return isDynamicStream ? (getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).maxAllowedIndex : mediaPlayerMaxAllowedDynamicStreamIndex;
		}
		
		public function set maxAllowedDynamicStreamIndex(value:int):void
		{			
			if (isDynamicStream)
			{
				(getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).maxAllowedIndex = value;
			}	
			
			mediaPlayerMaxAllowedDynamicStreamIndex = value;
			mediaPlayerMaxAllowedDynamicStreamIndexSet = true;
		}
		
		/**
		 * Indicates whether or not a dynamic stream switch is currently in progress.
		 * This property will return <code>true</code> while a switch has been 
		 * requested and the switch has not yet been acknowledged and no switch failure 
		 * has occurred.  Once the switch request has been acknowledged or a 
		 * failure occurs, the property will return <code>false</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get dynamicStreamSwitching():Boolean
		{
			return isDynamicStream ? (getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).switching : false;
		}
		
		/**
		 * Indicates whether or not an alternative audio stream switch is currently 
		 * in progress.
		 * 
		 * This property will return <code>true</code> while an audio stream switch 
		 * has been requested and the switch has not yet been acknowledged and no 
		 * switch failure has occurred. Once the switch request has been acknowledged
		 * or a failure occurs, the property will return <code>false</code>.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public function get alternativeAudioStreamSwitching():Boolean
		{
			return hasAlternativeAudio ? (getTraitOrThrow(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait).switching : false;
		}

		/**
		 * Switch to a specific dynamic stream index. To switch up, use the <code>currentDynamicStreamIndex</code>
		 * property, such as:<p>
		 * <code>
		 * mediaPlayer.switchDynamicStreamIndex(mediaPlayer.currentDynamicStreamIndex + 1);
		 * </code>
		 * </p>
		 * Note:  If the media is paused, switching will not take place until after play resumes. 
		 * @throws RangeError If the specified dynamic stream index is less than zero or
		 * greater than <code>maxAllowedDynamicStreamIndex</code>.
		 * @throws IllegalOperationError If the media is not a dynamic stream, or if the dynamic
		 * stream is not in manual switch mode.
		 * 
		 * @see maxAllowedDynamicStreamIndex
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function switchDynamicStreamIndex(streamIndex:int):void
		{
			(getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).switchTo(streamIndex);
		}	    
	
		/**
		 * Changes the current audio stream to the alternative audio stream specified by a 
		 * 0-based index value. Passing <code>-1</code> as the index value resets the current 
		 * audio stream to the default audio stream.
		 * 
		 * Note that if media playback is paused, the audio stream switch does not occur 
		 * until after play resumes.
		 * 
		 * @throws  RangeError if the specified alternative audio stream index is less than 
		 * 			<code>-1</code> or greater than <code>numAlternativeAudioStreams - 1</code>.
		 * @throws  IllegalOperationError if the currently loaded media does not have
		 * 			any associated alternative audio streams.
		 *  
		 * @langversion 3.0
		 * @playerversion Flash 10
		 * @playerversion AIR 1.5
		 * @productversion OSMF 1.6
		 */
		public function switchAlternativeAudioIndex(streamIndex:int):void
		{
			(getTraitOrThrow(MediaTraitType.ALTERNATIVE_AUDIO) as AlternativeAudioTrait).switchTo(streamIndex);
		}	    

		/**
		 * DisplayObject for the media.
         *  
         *  @langversion 3.0
         *  @playerversion Flash 10
         *  @playerversion AIR 1.5
         *  @productversion OSMF 1.0
         */
	    public function get displayObject():DisplayObject
	    {
	    	return _hasDisplayObject ? (getTraitOrThrow(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait).displayObject : null;	
	    }
	
		 /**
		 * Duration of the media's playback, in seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
	    public function get duration():Number
	    {
	    	return temporal ? (getTraitOrThrow(MediaTraitType.TIME) as TimeTrait).duration : 0;	    	
	    }
	  	  
    	/**
		 * Current time of the playhead in seconds.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		    
	    public function get currentTime():Number
	    {
	    	return temporal ? (getTraitOrThrow(MediaTraitType.TIME) as TimeTrait).currentTime : 0;
	    }
	    	    
	    /**
		 * Indicates whether the media is currently buffering.
		 * 
		 * <p>The default is <code>false</code>.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get buffering():Boolean
		{
			return canBuffer ? (getTraitOrThrow(MediaTraitType.BUFFER) as BufferTrait).buffering : false;	    	
		}
		
		/**
		 * Length of the content currently in the media's
		 * buffer, in seconds. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get bufferLength():Number
		{
			return canBuffer ? (getTraitOrThrow(MediaTraitType.BUFFER) as BufferTrait).bufferLength : 0;	    	
		}
		
		/**
		 * Desired length of the media's buffer, in seconds.
		 * 
		 * <p>If the passed value is non numerical or negative, it
		 * is forced to zero.</p>
		 * 
		 * <p>The default is zero.</p> 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get bufferTime():Number
		{
			return canBuffer ? (getTraitOrThrow(MediaTraitType.BUFFER) as BufferTrait).bufferTime : mediaPlayerBufferTime;		    	
		}
		
		public function set bufferTime(value:Number):void
		{
			var doDispatchEvent:Boolean = false;
			
			if (canBuffer)
			{
				(getTraitOrThrow(MediaTraitType.BUFFER) as BufferTrait).bufferTime = value;
			}	
			else if (value != mediaPlayerBufferTime)
			{
				doDispatchEvent = true;
			}
					
			mediaPlayerBufferTime = value;
			mediaPlayerBufferTimeSet = true;
			
			if (doDispatchEvent)
			{
				dispatchEvent(new BufferEvent(BufferEvent.BUFFER_TIME_CHANGE, false, false, buffering, mediaPlayerBufferTime));
			}			
		}
		
		/**
		 * The number of bytes of the media that have been loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get bytesLoaded():Number
		{
			var bytes:Number = 0;
			
			if (canLoad)
			{
				bytes = (getTraitOrThrow(MediaTraitType.LOAD) as LoadTrait).bytesLoaded;
				if (isNaN(bytes))
				{
					bytes = 0;
				}
			}
			
			return bytes;
		}
		
		/**
		 * The total number of bytes of the media that will be loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get bytesTotal():Number
		{
			var bytes:Number = 0;
			
			if (canLoad)
			{
				bytes = (getTraitOrThrow(MediaTraitType.LOAD) as LoadTrait).bytesTotal;
				if (isNaN(bytes))
				{
					bytes = 0;
				}
			}
			
			return bytes;
		}
	
		/**
		 * Authenticates the media.  Can be used for both anonymous and credential-based
		 * authentication.  If the media has already been authenticated or authentication 
		 * is anonymous, this is a no-op.
		 * 
		 * @param username The username.
		 * @param password The password.
		 * 
		 * @throws IllegalOperationError If the media is not initialized yet, or hasDRM
		 * is false.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function authenticate(username:String = null, password:String = null):void
		{
			(getTraitOrThrow(MediaTraitType.DRM) as DRMTrait).authenticate(username, password);		
		}
		
		
		/**
		 * Authenticates the media using an object which serves as a token.  Can be used
		 * for both anonymous and credential-based authentication.  If the media has
		 * already been authenticated or if the media isn't drm protected, this is a no-op.
		 * 
		 * @param token The token to use for authentication.
		 * 
		 * @throws IllegalOperationError If the media is not initialized yet, or hasDRM
		 * is false.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function authenticateWithToken(token:Object):void
		{	
			(getTraitOrThrow(MediaTraitType.DRM) as DRMTrait).authenticateWithToken(token);						
		}
		
		/**
		 * The current state of the DRM for this media.  The states are explained
		 * in the DRMState enumeration in the org.osmf.drm package.  Returns 
		 * DRMState.UNINITIALIZED if hasDRM is false.
		 * 
		 * @see DRMState
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get drmState():String
		{
			return hasDRM ? DRMTrait(media.getTrait(MediaTraitType.DRM)).drmState : DRMState.UNINITIALIZED;;
		}  

		/**
		 * Returns the start date for the playback window.  Returns null if authentication 
		 * hasn't taken place or if hasDRM is false.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get drmStartDate():Date
		{
			return hasDRM ? DRMTrait(media.getTrait(MediaTraitType.DRM)).startDate : null;
		}
		
		/**
		 * Returns the end date for the playback window.  Returns null if authentication 
		 * hasn't taken place or if if hasDRM is false.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get drmEndDate():Date
		{
			return hasDRM ? DRMTrait(media.getTrait(MediaTraitType.DRM)).endDate : null;
		}
		
		/**
		 * Returns the length of the playback window, in seconds.  Returns NaN if
		 * authentication hasn't taken place or if hasDRM is false.
		 * 
		 * Note that this property will generally be the difference between startDate
		 * and endDate, but is included as a property because there may be times where
		 * the duration is known up front, but the start or end dates are not (e.g. a
		 * one week rental).
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function get drmPeriod():Number
		{
			return hasDRM ? DRMTrait(media.getTrait(MediaTraitType.DRM)).period : NaN;
		}
		
		/**
		 * Returns true if the media is DVR-enabled and currently recording, false if
		 * the media is either not DVR-enabled, or is DVR-enabled but not currently
		 * recording.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 **/
		public function get isDVRRecording():Boolean
		{
			var dvrTrait:DVRTrait = media != null ? media.getTrait(MediaTraitType.DVR) as DVRTrait : null;
			return dvrTrait != null ? dvrTrait.isRecording : false;
		}
	
		// Internals
		//
	    
	    private function getTraitOrThrow(traitType:String):MediaTraitBase
	    {
	    	if (!media || !media.hasTrait(traitType)) 
	    	{
	    		var error:String = OSMFStrings.getString(OSMFStrings.CAPABILITY_NOT_SUPPORTED);
	    		var traitName:String = traitType.replace("[class ", "");
	    		traitName = traitName.replace("]", "").toLowerCase();	
	    				
	    		error = error.replace('*trait*', traitName);
	    			    		
	    		throw new IllegalOperationError(error);		    		
	    	}
	    	return media.getTrait(traitType);
	    }

	    private function onMediaError(event:MediaErrorEvent):void
	    {
	    	// Note that all MediaErrors are treated as playback errors.  If
	    	// necessary, we could introduce a distinction between errors and
	    	// warnings (non-fatal errors).  But the current assumption is
	    	// that we don't need to do so (no compelling use cases exist).
	    	setState(MediaPlayerState.PLAYBACK_ERROR);
	    	
	    	dispatchEvent(event.clone());
	    }
	        
		private function onTraitAdd(event:MediaElementEvent):void
		{				
			updateTraitListeners(event.traitType, true);				
		}
		
		private function onTraitRemove(event:MediaElementEvent):void
		{
			updateTraitListeners(event.traitType, false);						
		}
		
		private function updateTraitListeners(traitType:String, add:Boolean, skipIfInErrorState:Boolean=true):void
		{
			// We circumvent this process if we're in an error state (and told
			// to skip this process if we're in an error state), under the
			/// assumption that we've already updated the trait listeners to
			// "hide" the traits as a result of entering the error state.  The
			// one exception to this is the LoadTrait, which is not hidden as
			// the result of a playback error.
			if (	state == MediaPlayerState.PLAYBACK_ERROR
				 && skipIfInErrorState
				 &&	traitType != MediaTraitType.LOAD
			   )
			{
				return;
			}
			
			// The default values on each trait property here are checked, events
			// are dispatched if the trait's value is different from the default
			// MediaPlayer's values.  Default values are listed in the ASDocs for
			// the various properties.
			
			// For added traits, the capability is updated (and change event
			// dispatched first).
			if (add)
			{
				updateCapabilityForTrait(traitType, add);
			}
			
			switch (traitType)
			{
				case MediaTraitType.TIME:								
					changeListeners(add, traitType, TimeEvent.COMPLETE, onComplete);		
					_temporal = add;
					if (add && _currentTimeUpdateInterval > 0 && !isNaN(_currentTimeUpdateInterval) )
					{
						_currentTimeTimer.start();
					}
					else
					{
						_currentTimeTimer.stop();					
					}					
					var timeTrait:TimeTrait = TimeTrait(media.getTrait(MediaTraitType.TIME));
										
					if (timeTrait.currentTime != 0 && _currentTimeUpdateInterval > 0 && !isNaN(_currentTimeUpdateInterval))
					{
						dispatchEvent(new TimeEvent(TimeEvent.CURRENT_TIME_CHANGE, false, false, currentTime));		
					}
					
					if (timeTrait.duration != 0)
					{
						dispatchEvent(new TimeEvent(TimeEvent.DURATION_CHANGE, false, false, duration));	
					}					
					break;
				case MediaTraitType.PLAY:						
					changeListeners(add, traitType, PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
					_canPlay = add;	
					var playTrait:PlayTrait = PlayTrait(media.getTrait(MediaTraitType.PLAY));
					if (autoPlay && canPlay && !playing && !inSeek)
					{
						play();
					}
					else if (playTrait.playState != PlayState.STOPPED)
					{
						dispatchEvent(new PlayEvent(PlayEvent.PLAY_STATE_CHANGE, false, false, add ? playTrait.playState : PlayState.STOPPED));
					}
					if (playTrait.canPause)
					{
						dispatchEvent(new PlayEvent(PlayEvent.CAN_PAUSE_CHANGE, false, false, null, add));
					}							
					break;	
				case MediaTraitType.AUDIO:		
					_hasAudio = add;
					var audioTrait:AudioTrait = AudioTrait(media.getTrait(MediaTraitType.AUDIO));
					if (mediaPlayerVolumeSet)
					{
						volume = mediaPlayerVolume;
					}
					else if (mediaPlayerVolume != audioTrait.volume)
					{
						dispatchEvent(new AudioEvent(AudioEvent.VOLUME_CHANGE, false, false, muted, volume, audioPan));
					}
					if (mediaPlayerMutedSet)
					{
						muted = mediaPlayerMuted;
					}
					else if (mediaPlayerMuted != audioTrait.muted)
					{
						dispatchEvent(new AudioEvent(AudioEvent.MUTED_CHANGE, false, false, muted,  volume, audioPan));
					}
					if (mediaPlayerAudioPanSet)
					{
						audioPan = mediaPlayerAudioPan;
					}
					else if (mediaPlayerAudioPan != audioTrait.pan)
					{
						dispatchEvent(new AudioEvent(AudioEvent.PAN_CHANGE, false, false, muted, volume, audioPan));
					}				
					break;
				case MediaTraitType.SEEK:
					changeListeners(add, traitType, SeekEvent.SEEKING_CHANGE, onSeeking);
					_canSeek = add;					
					if (SeekTrait(media.getTrait(MediaTraitType.SEEK)).seeking && !inExecuteAutoRewind)
					{
						dispatchEvent(new SeekEvent(SeekEvent.SEEKING_CHANGE, false, false, add));
					}					
					break;
				case MediaTraitType.DYNAMIC_STREAM:					
					_isDynamicStream = add;	
					var dynamicStreamTrait:DynamicStreamTrait = DynamicStreamTrait(media.getTrait(MediaTraitType.DYNAMIC_STREAM));
					if (mediaPlayerMaxAllowedDynamicStreamIndexSet)
					{
						maxAllowedDynamicStreamIndex = mediaPlayerMaxAllowedDynamicStreamIndex;
					}					
					if (mediaPlayerAutoDynamicStreamSwitchSet)
					{
						autoDynamicStreamSwitch = mediaPlayerAutoDynamicStreamSwitch;
					}
					else if (mediaPlayerAutoDynamicStreamSwitch != dynamicStreamTrait.autoSwitch)
					{
						dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.AUTO_SWITCH_CHANGE, false, false, dynamicStreamSwitching, autoDynamicStreamSwitch)); 
					}
					if (dynamicStreamTrait.switching) //If we are in the middle of a switch, notify.
					{
						dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.SWITCHING_CHANGE, false, false, dynamicStreamSwitching, autoDynamicStreamSwitch));
					}
					dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, false, false, dynamicStreamSwitching, autoDynamicStreamSwitch));
					break;						
				case MediaTraitType.ALTERNATIVE_AUDIO:					
					_hasAlternativeAudio = add;	
					var alternativeAudioTrait:AlternativeAudioTrait = AlternativeAudioTrait(media.getTrait(MediaTraitType.ALTERNATIVE_AUDIO));
					if (alternativeAudioTrait.switching && add) 
					{
						dispatchEvent(new AlternativeAudioEvent(AlternativeAudioEvent.AUDIO_SWITCHING_CHANGE, false, false, alternativeAudioTrait.switching));
					}
					dispatchEvent(new AlternativeAudioEvent(AlternativeAudioEvent.NUM_ALTERNATIVE_AUDIO_STREAMS_CHANGE, false, false, alternativeAudioTrait.switching && add));
					break;						
				case MediaTraitType.DISPLAY_OBJECT:						
					_hasDisplayObject = add;
					var displayObjectTrait:DisplayObjectTrait = DisplayObjectTrait(media.getTrait(MediaTraitType.DISPLAY_OBJECT));
					if (displayObjectTrait.displayObject != null)
					{
						dispatchEvent(new DisplayObjectEvent(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, false, false, null, displayObject, NaN, NaN, mediaWidth, mediaHeight));
					}
					if (!isNaN(displayObjectTrait.mediaHeight) || !isNaN(displayObjectTrait.mediaWidth))
					{
						dispatchEvent(new DisplayObjectEvent(DisplayObjectEvent.MEDIA_SIZE_CHANGE, false, false, null, displayObject, NaN, NaN, mediaWidth, mediaHeight));
					}					
					break;	
				case MediaTraitType.LOAD:					
					changeListeners(add, traitType, LoadEvent.LOAD_STATE_CHANGE, onLoadState);			
					_canLoad = add;		
					var loadTrait:LoadTrait = LoadTrait(media.getTrait(MediaTraitType.LOAD));
					if (loadTrait.bytesLoaded > 0)
					{
						dispatchEvent(new LoadEvent(LoadEvent.BYTES_LOADED_CHANGE, false, false, null, bytesLoaded));
					}
					if (loadTrait.bytesTotal > 0)
					{
						dispatchEvent(new LoadEvent(LoadEvent.BYTES_TOTAL_CHANGE, false, false, null, bytesTotal));
					}	
					if (add)
					{
						var loadState:String = (media.getTrait(traitType) as LoadTrait).loadState;
						if (loadState != LoadState.READY && 
							loadState != LoadState.LOADING)
						{
							load();
						}
						else if (autoPlay && canPlay && !playing)
						{
							play();	
						}
						
						if (_bytesLoadedUpdateInterval > 0 && !isNaN(_bytesLoadedUpdateInterval))
						{
							_bytesLoadedTimer.start();
						}
						else
						{
							_bytesLoadedTimer.stop();					
						}			
					}										
					break;		
				case MediaTraitType.BUFFER:
					changeListeners(add, traitType, BufferEvent.BUFFERING_CHANGE, onBuffering);					
					_canBuffer = add;
					var bufferTrait:BufferTrait = BufferTrait(media.getTrait(MediaTraitType.BUFFER));
					if (mediaPlayerBufferTimeSet)
					{
						bufferTime = mediaPlayerBufferTime;	
					}
					else if (mediaPlayerBufferTime != bufferTrait.bufferTime)
					{
						dispatchEvent(new BufferEvent(BufferEvent.BUFFER_TIME_CHANGE, 
							false, 
							false, 
							false,
							bufferTime));
					}
					if (bufferTrait.buffering)
					{
						dispatchEvent(new BufferEvent(BufferEvent.BUFFERING_CHANGE, false, false, buffering));
					}					
					break;	
				case MediaTraitType.DRM:					
					_hasDRM	= add; 
					dispatchEvent(new DRMEvent(DRMEvent.DRM_STATE_CHANGE, drmState, false, false, drmStartDate, drmEndDate, drmPeriod));
					break;			
			}
			
			// For removed traits, the capability is updated (and change event dispatched)
			// last.
			if (add == false)
			{
				updateCapabilityForTrait(traitType, false);
			}	
		}
		
		private function updateCapabilityForTrait(traitType:String, capabilityAdd:Boolean):void
		{
			var eventType:String = null;
			
			switch (traitType)
			{
				case MediaTraitType.AUDIO:
					eventType = MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE;
					_hasAudio = capabilityAdd;
					break;				
				case MediaTraitType.BUFFER:
					eventType = MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE;
					_canBuffer = capabilityAdd;
					break;	
				case MediaTraitType.DISPLAY_OBJECT:						
					eventType = MediaPlayerCapabilityChangeEvent.HAS_DISPLAY_OBJECT_CHANGE;
					break;				
				case MediaTraitType.DRM:					
					eventType = MediaPlayerCapabilityChangeEvent.HAS_DRM_CHANGE;
					_hasDRM = capabilityAdd;
					break;
				case MediaTraitType.DYNAMIC_STREAM:
					eventType = MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE;
					_isDynamicStream = capabilityAdd;
					break;				
				case MediaTraitType.ALTERNATIVE_AUDIO:
					eventType = MediaPlayerCapabilityChangeEvent.HAS_ALTERNATIVE_AUDIO_CHANGE;
					_hasAlternativeAudio = capabilityAdd;
					break;				
				case MediaTraitType.LOAD:					
					eventType = MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE;
					_canLoad = capabilityAdd;
					break;				
				case MediaTraitType.PLAY:
					eventType = MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE;
					_canPlay = capabilityAdd;
					break;				
				case MediaTraitType.SEEK:
					eventType = MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE;
					_canSeek = capabilityAdd;
					break;				
				case MediaTraitType.TIME:
					eventType = MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE;
					_temporal = capabilityAdd;
					break;				
			}
			
			if (eventType != null)
			{
				dispatchEvent
						( new MediaPlayerCapabilityChangeEvent
							( eventType
							, false
							, false
							, capabilityAdd
							)
						);
			}
		}
		
		// Add any number of listeners to the trait, using the given event name.
		private function changeListeners(add:Boolean, traitType:String, event:String, listener:Function):void
		{			
			if (add)
			{
				// Make sure that the MediaPlayer gets to process the event
				// before it gets redispatched to the client.  This will
				// ensure that we present a consistent state to the client.
				var priority:int = 1;				
				media.getTrait(traitType).addEventListener(event, listener, false, priority);
			}
			else if (media.hasTrait(traitType))
			{		
				media.getTrait(traitType).removeEventListener(event, listener);
			}		
		}
		
		private function onSeeking(event:SeekEvent):void
		{
			mediaAtEnd = false;
			
			if (event.type == SeekEvent.SEEKING_CHANGE && event.seeking)
			{				
				setState(MediaPlayerState.BUFFERING);				
			}
			else if (canPlay && playing)
			{
				setState(MediaPlayerState.PLAYING);
			}
			else if (canPlay && paused)
			{
				setState(MediaPlayerState.PAUSED);
			}	
			else if (canBuffer && buffering)
			{
				setState(MediaPlayerState.BUFFERING);
			}					
			else if (!inExecuteAutoRewind)
			{
				setState(MediaPlayerState.READY);
			}				
		}
				
		private function onPlayStateChange(event:PlayEvent):void
		{			
			if (event.playState == PlayState.PLAYING)  
			{
				// Don't signal playing until we've buffered some data.
				if (canBuffer == false || bufferLength > 0 || bufferTime < 0.001)
				{
					setState(MediaPlayerState.PLAYING);
				}
			}
			else if (event.playState == PlayState.PAUSED)
			{
				setState(MediaPlayerState.PAUSED);				
			}
		}

		private function onLoadState(event:LoadEvent):void
		{
			if (event.loadState == LoadState.READY && 
				state == MediaPlayerState.LOADING)
			{
				processReadyState();
			}
			else if (event.loadState == LoadState.UNINITIALIZED)
			{				
				setState(MediaPlayerState.UNINITIALIZED);
			}	
			else if (event.loadState == LoadState.LOAD_ERROR)
			{
				setState(MediaPlayerState.PLAYBACK_ERROR);
			}	
			else if (event.loadState == LoadState.LOADING)
			{				
				setState(MediaPlayerState.LOADING);
			}			
		}
		
		private function processReadyState():void
		{
			setState(MediaPlayerState.READY);
			if (autoPlay && canPlay && !playing)
			{
				play();
			}
		}
		
		private function onComplete(event:TimeEvent):void
		{
			mediaAtEnd = true;
			
			if (loop && canSeek && canPlay)
			{
				executeAutoRewind(true);
			}
			else if (!loop && canPlay)
			{
				// Stop, but don't auto-rewind unless autoRewind is true.
				(getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).stop();
				
				if (autoRewind && canSeek)
				{
					executeAutoRewind(false);
				}
				else
				{
					setState(MediaPlayerState.READY);
				}
			}
			else
			{
				setState(MediaPlayerState.READY);
			}
		}	
		
		private function executeAutoRewind(playAfterAutoRewind:Boolean):void
		{
			if (inExecuteAutoRewind == false)
			{
				inExecuteAutoRewind = true;
				mediaAtEnd = false;
				
	 			addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
				function onSeekingChange(event:SeekEvent):void
				{
					if (event.seeking == false)
					{
						removeEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange);
						if (playAfterAutoRewind)
						{
							play();
						}
						else
						{
							setState(MediaPlayerState.READY);
						}
						
						inExecuteAutoRewind = false;
					}
				}
				seek(0);
			}							
		}
								
		private function onCurrentTimeTimer(event:TimerEvent):void
		{
			if (temporal && 
				currentTime != lastCurrentTime && 
			 	(!canSeek || !seeking) )
			{				
				lastCurrentTime = currentTime;
				dispatchEvent(new TimeEvent(TimeEvent.CURRENT_TIME_CHANGE, false, false, currentTime));
			}
		}	
		
		private function onBytesLoadedTimer(event:TimerEvent):void
		{
			if (canLoad && (bytesLoaded != lastBytesLoaded))
			{
				var bytesLoadedEvent:LoadEvent 
					= new LoadEvent
						( LoadEvent.BYTES_LOADED_CHANGE
						, false
						, false
						, null
						, bytesLoaded
						);
						 	
				lastBytesLoaded = bytesLoaded;
				
				dispatchEvent(bytesLoadedEvent);
			}
		}
		
		private function onBuffering(event:BufferEvent):void
		{			
			if (event.buffering)
			{
				setState(MediaPlayerState.BUFFERING);
			}
			else
			{
				if (canPlay && playing)
				{
					setState(MediaPlayerState.PLAYING);					
				}
				else if (canPlay && paused)
				{
					setState(MediaPlayerState.PAUSED);
				}
				else
				{
					setState(MediaPlayerState.READY);	
				}				
			}
		}
		
		private function setState(newState:String):void
		{
			if (_state != newState)
			{
				_state = newState;
				dispatchEvent
					( new MediaPlayerStateChangeEvent
						( MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE
						, false
						, false
						, _state
						)
					);
				
				// If we're entering an error state, we "disable" all traits
				// but the LoadTrait.  The reasoning is that the MediaElement
				// is in an inconsistent, possibly unusable state, and we don't
				// want to expose capabilities (e.g. canPlay) which don't
				// reflect reality.
				if (newState == MediaPlayerState.PLAYBACK_ERROR)
				{
					var playing:Boolean = playing;
					//Stops all media playing (specificaly in parallel cases)					
					for each (var traitType:String in media.traitTypes)
					{
						if (traitType != MediaTraitType.LOAD)
						{
							updateTraitListeners(traitType, false, false);
						}
					}
					if (playing)						
					{
						(getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).stop();
					}
				}
			}
		}
		
		private function load():void
		{
			try
			{
				var loadTrait:LoadTrait = media.getTrait(MediaTraitType.LOAD) as LoadTrait;
				
				// If it's LOADING, then let's wait for it to load.  If it's
				// READY, then there's nothing for us to do.
				if (	loadTrait.loadState != LoadState.LOADING
					&&	loadTrait.loadState != LoadState.READY
				   )
				{
					loadTrait.load();
				}
			}
			catch (error:IllegalOperationError)
			{
				setState(MediaPlayerState.PLAYBACK_ERROR);
				
				dispatchEvent
					( new MediaErrorEvent
						( MediaErrorEvent.MEDIA_ERROR
						, false
						, false
						, new MediaError(MediaErrorCodes.MEDIA_LOAD_FAILED, error.message)
						)
					);
			}
		}
					
	    private static const DEFAULT_UPDATE_INTERVAL:Number = 250;
	      
	    private var lastCurrentTime:Number = 0;	
	    private var lastBytesLoaded:Number = NaN;	
		private var _autoPlay:Boolean = true;
		private var _autoRewind:Boolean = true;
		private var _loop:Boolean = false;		
		private var _currentTimeUpdateInterval:Number = DEFAULT_UPDATE_INTERVAL;
		private var _currentTimeTimer:Timer  = new Timer(DEFAULT_UPDATE_INTERVAL);
		private var _state:String; // MediaPlayerState
		private var _bytesLoadedUpdateInterval:Number = DEFAULT_UPDATE_INTERVAL;
		private var _bytesLoadedTimer:Timer = new Timer(DEFAULT_UPDATE_INTERVAL);
		private var inExecuteAutoRewind:Boolean = false;
		private var inSeek:Boolean = false;
		private var mediaAtEnd:Boolean = false;
		
		// Persistent properties of the MediaPlayer, as opposed to properties that apply
		// to a specific MediaElement.  We use xxxSet Booleans to determine
		// if a property has been set by a 
		private var mediaPlayerVolume:Number = 1;
		private var mediaPlayerVolumeSet:Boolean = false;
		private var mediaPlayerMuted:Boolean = false;
		private var mediaPlayerMutedSet:Boolean = false;
		private var mediaPlayerAudioPan:Number = 0;
		private var mediaPlayerAudioPanSet:Boolean = false;
		private var mediaPlayerBufferTime:Number = 0;
		private var mediaPlayerBufferTimeSet:Boolean = false;
		private var mediaPlayerMaxAllowedDynamicStreamIndex:int = 0;
		private var mediaPlayerMaxAllowedDynamicStreamIndexSet:Boolean = false;
		private var mediaPlayerAutoDynamicStreamSwitch:Boolean = true;
		private var mediaPlayerAutoDynamicStreamSwitchSet:Boolean = false;
		
		
		private var _canPlay:Boolean;
		private var _canSeek:Boolean;
		private var _temporal:Boolean;
		private var _hasAudio:Boolean;
		private var _hasDisplayObject:Boolean;
		private var _canLoad:Boolean;
		private var _canBuffer:Boolean;
		private var _isDynamicStream:Boolean;
		private var _hasAlternativeAudio:Boolean;
		private var _hasDRM:Boolean;
	}
}
