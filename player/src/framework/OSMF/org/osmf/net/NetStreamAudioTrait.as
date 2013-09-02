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
package org.osmf.net
{
	import flash.media.SoundTransform;
	import flash.net.NetStream;
	
	import org.osmf.traits.AudioTrait;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * The NetStreamAudioTrait class extends AudioTrait for NetStream audio.
	 * 
	 * <p>Sets the soundTransform object on the NetStream in response to audio
	 * property changes.</p>
	 */ 
	public class NetStreamAudioTrait extends AudioTrait
	{
		/**
		 * Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function NetStreamAudioTrait(netStream:NetStream)
		{
			super();
			
			this.netStream = netStream;
		}
		
		override protected function volumeChangeStart(newVolume:Number):void
		{
			var soundTransform:SoundTransform = netStream.soundTransform;				
			soundTransform.volume = muted ? 0 : newVolume;
			netStream.soundTransform = soundTransform;
		}
		
		override protected function mutedChangeStart(newMuted:Boolean):void
		{
			var soundTransform:SoundTransform = netStream.soundTransform;			
			soundTransform.volume = newMuted ? 0 : volume;
			netStream.soundTransform = soundTransform;
		}

		override protected function panChangeStart(newPan:Number):void
		{
			var soundTransform:SoundTransform = netStream.soundTransform;					
			soundTransform.pan = newPan;
			netStream.soundTransform = soundTransform;
		}
				
		private var netStream:NetStream;		
	}
}