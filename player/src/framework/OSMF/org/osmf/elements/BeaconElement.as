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
	import org.osmf.elements.beaconClasses.Beacon;
	import org.osmf.elements.beaconClasses.BeaconPlayTrait;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitType;
	
	/**
	 * BeaconElement is a media element which maps the "play" operation to the
	 * request (via an HTTP GET) of a URL.
	 *
	 *  @includeExample BeaconElementExample.as -noswf
	 * 
  	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class BeaconElement extends MediaElement
	{
		/**
		 * Constructor.
		 * 
		 * @param url The URL to retrieve (via an HTTP GET) when this
		 * BeaconElement is played.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function BeaconElement(url:String)
		{
			this.url = url;

			super();
		}
		
		/**
		 * @private
		 */
		override protected function setupTraits():void
		{
			addTrait(MediaTraitType.PLAY, new BeaconPlayTrait(createBeacon()));
		}
		
		/**
		 * @private
		 **/
		protected function createBeacon():Beacon
		{
			return new Beacon(url);
		}

		private var url:String;
	}
}