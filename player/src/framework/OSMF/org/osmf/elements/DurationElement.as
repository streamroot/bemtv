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
package org.osmf.elements
{
	import __AS3__.vec.Vector;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.elements.proxyClasses.DurationSeekTrait;
	import org.osmf.elements.proxyClasses.DurationTimeTrait;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	/**
	 * DurationElement is a media element that wraps a MediaElement to give it
	 * temporal capabilities.
	 * It allows a non-temporal MediaElement to be treated as a temporal MediaElement.
	 * <p>The DurationElement class is especially useful for creating delays
	 * in the presentation of a media composition.
	 * For example, the following code presents a sequence of videos,
	 * separated from each other by five-second delays.</p>
	 * <listing>
	 * var sequence:SerialElement = new SerialElement();
	 * 
	 * sequence.addChild(new VideoElement(new URLResource("http://www.example.com/video1.flv")));
	 * sequence.addChild(new DurationElement(5));
	 * sequence.addChild(new VideoElement(new URLResource("http://www.example.com/ad.flv")));
	 * sequence.addChild(new DurationElement(5));
	 * sequence.addChild(new VideoElement(new URLResource("http://www.example.com/video2.flv")));
	 * 
	 * // Assign the SerialElement to the MediaPlayer.
	 * player.media = sequence;
	 * </listing>
	 * <p>The following example presents a sequence of rotating banners.
	 * The delays separating the appearances of the banners are 
	 * created with DurationElements.
	 * In addition, the images themselves are wrapped in DurationElements
	 * to enable them to support a duration.</p>
	 * <listing>
	 * // The first banner does not appear for five seconds.
	 * // Each banner is shown for 20 seconds.
	 * // There is a 15-second delay between images.
	 * 
	 * var bannerSequence:SerialElement = new SerialElement();
	 * 
	 * bannerSequence.addChild(new DurationElement(5));
	 * bannerSequence.addChild(new DurationElement(20,new ImageElement(new URLResource("http://www.example.com/banner1.jpg")));
	 * bannerSequence.addChild(new DurationElement(15));
	 * bannerSequence.addChild(new DurationElement(20,new ImageElement(new URLResource("http://www.example.com/banner2.jpg")));
	 * bannerSequence.addChild(new DurationElement(15));
	 * bannerSequence.addChild(new DurationElement(20,new ImageElement(new URLResource("http://www.example.com/banner3.jpg")));
	 * </listing>
	 * 
	 * The DurationElement will not work with elements that already have a TimeTrait, such
	 * as VideoElement.  To specify a start and end time for a VideoElement. use
	 * StreamingURLResource's <code>clipStartTime</code> and <code>clipEndTime</code> properties.
	 * 
	 * @includeExample DurationElementExample.as -noswf
	 * 
	 * @see org.osmf.elements.ProxyElement
	 * @see org.osmf.elements.SerialElement
	 * @see org.osmf.net.StreamingURLResource
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class DurationElement extends ProxyElement
	{
		/**
	 	 * Constructor.
	 	 * 
	 	 * @param duration Duration of the DurationElement's TimeTrait, in seconds.
	 	 * @param mediaElement Optional element to be wrapped by this DurationElement.
	 	 *  
	 	 *  @langversion 3.0
	 	 *  @playerversion Flash 10
	 	 *  @playerversion AIR 1.5
	 	 *  @productversion OSMF 1.0
	 	 */		
		public function DurationElement(duration:Number, mediaElement:MediaElement=null)
		{
			_duration = duration;
			
			// Prepare the position timer.
			playheadTimer = new Timer(DEFAULT_PLAYHEAD_UPDATE_INTERVAL);
			playheadTimer.addEventListener(TimerEvent.TIMER, onPlayheadTimer, false, 0, true);
			
			super(mediaElement != null ? mediaElement : new MediaElement());
		}
		
		/**
		 * @private
		 * 
	 	 * Sets up the element's TimeTrait, SeekTrait, and PlayTrait.
	 	 * The proxy's traits will override the same traits in the wrapped element.
	 	 * <p>This gives the application access to the trait properties in the wrapped
	 	 * element that did not exist before it was wrapped.</p>
	 	 * <p>For example, the DurationElement in the following line wraps an ImageElement.
	 	 * The <code>duration</code> property of the DurationElement's TimeTrait allows
	 	 * the application to specify the duration that the image is displayed, in this case 20 seconds.</p>
	 	 * <listing>
	 	 * bannerSequence.addChild(new DurationElement(20,new ImageElement(new ImageLoader(),
	 	 * 	new URLResource("http://www.example.com/banner1.jpg")));	
	 	 * </listing>
	 	 */	
		override protected function setupTraits():void
		{
			super.setupTraits();
			
			timeTrait = new DurationTimeTrait(_duration);
			
			// Increase the priority for our onComplete handler, so that we can get the
			// event first and present a consistent view to clients.
			timeTrait.addEventListener(TimeEvent.COMPLETE, onComplete, false, int.MAX_VALUE);
			addTrait(MediaTraitType.TIME, timeTrait);

			seekTrait = new DurationSeekTrait(timeTrait);
			addTrait(MediaTraitType.SEEK, seekTrait);
			
			// Reduce priority of our listener so that all other listeners will
			// receive the seeking=true event before we dispatch the seeking=false
			// event. 
			seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE, onSeekingChange, false, -1);
			
			playTrait = new PlayTrait();
			playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
			addTrait(MediaTraitType.PLAY, playTrait);
			
			// Block all other traits, we'll unblock them once we're playing.
			blockedTraits = ALL_OTHER_TRAITS;
		}
		
		// Internals
		//

		private function onPlayheadTimer(event:TimerEvent):void
		{
			if (currentTime >= _duration)
			{
				playheadTimer.stop();
				playTrait.stop();

				currentTime = _duration;
			}
			else
			{
				// Increment our currentTime on each Timer tick.
				currentTime = (flash.utils.getTimer() - absoluteStartTime)/1000;
			}
		}
		
		private function onPlayStateChange(event:PlayEvent):void
		{
			if (event.playState == PlayState.PLAYING)
			{
				if (mediaAtEnd)
				{
					mediaAtEnd = false;
					currentTime = 0;
				} 
				
				// When play starts, we reset our absoluteStartTime based on
				// what our currentTime is.
				absoluteStartTime = flash.utils.getTimer() - currentTime*1000;
				playheadTimer.start();
			}
			else
			{
				playheadTimer.stop();
				
			}
			
			// When the element is neither playing nor paused, block exposure
			// of all non-overridden traits.
			if (event.playState != PlayState.STOPPED && currentTime < _duration)
			{
				blockedTraits = NO_TRAITS;
			}
			else
			{
				blockedTraits = ALL_OTHER_TRAITS;
			}

		}
		
		private function onSeekingChange(event:SeekEvent):void
		{
			mediaAtEnd = false;
			
			if (event.seeking)
			{
				// Adjust the currentTime and absoluteStartTime by the seek amount.
				var diff:Number = event.time - currentTime;
				currentTime = event.time;
				absoluteStartTime -= diff*1000;
			}
			else
			{
				// When the the user seeks outside the range of this element, block
				// exposure of all non-overridden traits.  When they seek into this
				// element, expose them again.  Note that we don't include currentTime
				// of zero as an unblocked case unless the media is playing, since
				// zero is usually the seek time for auto-rewound media.
				if (	currentTime < _duration
					&&	(currentTime > 0 || playTrait.playState == PlayState.PLAYING)
				   )
				{
					blockedTraits = NO_TRAITS;
				}
				else
				{
					blockedTraits = ALL_OTHER_TRAITS;
				}
			}
		}

		private function onComplete(event:TimeEvent):void
		{
			playheadTimer.stop();
			playTrait.stop();
			mediaAtEnd = true;
			
			// When playback completes, block exposure of all non-overridden traits.
			blockedTraits = ALL_OTHER_TRAITS;
		}
				
		private function get currentTime():Number
		{
			return _currentTime;
		}
		
		private function set currentTime(value:Number):void
		{
			_currentTime = value;
			timeTrait.currentTime = value;
		}
		
		private static const DEFAULT_PLAYHEAD_UPDATE_INTERVAL:Number = 250;
		private static const NO_TRAITS:Vector.<String> = new Vector.<String>();
		private static const ALL_OTHER_TRAITS:Vector.<String> = new Vector.<String>();
		{
			// Everything but LOAD, SEEK, PLAY, and TIME.
			ALL_OTHER_TRAITS.push(MediaTraitType.AUDIO);
			ALL_OTHER_TRAITS.push(MediaTraitType.BUFFER);
			ALL_OTHER_TRAITS.push(MediaTraitType.DISPLAY_OBJECT);
			ALL_OTHER_TRAITS.push(MediaTraitType.DRM);
			ALL_OTHER_TRAITS.push(MediaTraitType.DVR);
			ALL_OTHER_TRAITS.push(MediaTraitType.DYNAMIC_STREAM);
		}
		
		private var _currentTime:Number = 0; // seconds
		private var _duration:Number = 0;	// seconds
		private var absoluteStartTime:Number = 0; // milliseconds
		private var playheadTimer:Timer;
		private var mediaAtEnd:Boolean = false;
		
		private var timeTrait:DurationTimeTrait;
		private var seekTrait:DurationSeekTrait;
		private var playTrait:PlayTrait;
	}
}