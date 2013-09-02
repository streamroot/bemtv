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
package org.osmf.traits
{
	import flash.events.EventDispatcher;
	
	/**
	 * A MediaTraitBase is the encapsulation of a trait or capability that's
	 * inherent to a MediaElement.  The sum of all traits on a media element
	 * define the overall capabilities of the media element.
	 * 
	 * <p>Media traits are first-class members of the object model for a
	 * number of reasons:</p>
	 * <ul>
	 * <li>
	 * Traits allow us to isolate common aspects of different media types into
	 * reusable building blocks.  For example, music and video may share a
	 * common implementation for audio.  An "audio" trait can encapsulate
	 * that common implementation in such a way that it can be used for both
	 * media types, while still providing a uniform interface to these
	 * different media types.
	 * </li>
	 * <li>
	 * Different media elements may have their capabilities change dynamically
	 * over time, and traits allow us to isolate these capabilities in such
	 * a way that we can clearly express that dynamism.  For example, a video
	 * player might not initially be "viewable", due to its need to be loaded
	 * before playback can begin.  Rather than express this dynamism through
	 * changes to a set of methods on a monolithic media class, we can express
	 * it through the presence or absence of a trait instance on a lighter
	 * weight media class.
	 * </li>
	 * <li>Traits make compositioning scalable.  (Compositioning is the ability
	 * to temporally and spatially composite collections of media.)  If traits
	 * represent the overall vocabulary of the media framework, then we can
	 * implement compositioning primarily in terms of the traits, rather than
	 * in terms of the media that aggregate those traits.  This approach allows
	 * developers to create new media implementations that can easily integrate
	 * with the compositioning parts of the framework without requiring changes
	 * to that framework.  Our working assumption, of course, is that most (if
	 * not all) media will generally share the same vocabulary, which can be
	 * expressed through a core set of media traits.
	 * </li>
	 * <li>Traits allow for uniform, media-agnostic <i>client</i> classes.  For
	 * example, if a client class is capable of rendering the "display object" trait,
	 * then it's capable of rendering any and all media that host that trait. </li>
	 * </ul>
	 * 
	 * <p>It's important to be aware of the relationship between a media trait
	 * and a media element.  Some media trait implementations will be tightly
	 * coupled to a specific type of media element, while others will be
	 * generic enough to work with any media element.  For example, an
	 * implementation of a "play" trait that works with video is typically
	 * going to be specific to one class of media elements, namely the class
	 * that plays video, since the playback operations will be specific to the
	 * underlying implementation of video (i.e. NetStream).  On the other hand,
	 * an implementation of a "display object" trait might be able to work with
	 * any media element, since DisplayObjectTrait will use the same underlying
	 *  media implementation (DisplayObject) for any media element.</p> 
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class MediaTraitBase extends EventDispatcher
	{
		/**
		 * Constructor.
		 * 
		 * @param traitType The MediaTraitType for this trait.  All possible values
		 * are described on the MediaTraitType enumeration.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function MediaTraitBase(traitType:String)
		{
			super();
			
			_traitType = traitType;
		}
		
		/**
		 * The MediaTraitType for this trait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get traitType():String
		{
			return _traitType;
		}
		
		/**
		 * Disposes of any resources used by this trait.  Called by the framework
		 * whenever a trait is removed from a MediaElement.
		 * 
		 * <p>Subclasses should override to do any disposal logic specific to their
		 * implementation.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function dispose():void
		{
		}
		
		private var _traitType:String;
	}
}