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
package org.osmf.elements.audioClasses
{
	import flash.media.SoundTransform;
	
	import org.osmf.traits.AudioTrait;

	[ExcludeClass]
	
	/**
	 * @private
	 **/
	public class AudioAudioTrait extends AudioTrait
	{
		public function AudioAudioTrait(soundAdapter:SoundAdapter)
		{
			super();
			
			this.soundAdapter = soundAdapter;
			soundAdapter.soundTransform.volume = volume;
			soundAdapter.soundTransform.pan = pan;
		}
		
		override protected function volumeChangeStart(newVolume:Number):void
		{
			var soundTransform:SoundTransform = soundAdapter.soundTransform;				
			soundTransform.volume = muted ? 0 : newVolume;
			soundAdapter.soundTransform = soundTransform;
		}

		override protected function mutedChangeStart(newMuted:Boolean):void
		{
			var soundTransform:SoundTransform = soundAdapter.soundTransform;			
			soundTransform.volume = newMuted ? 0 : volume;
			soundAdapter.soundTransform = soundTransform;
		}
		
		override protected function panChangeStart(newPan:Number):void
		{
			var soundTransform:SoundTransform = soundAdapter.soundTransform;					
			soundTransform.pan = newPan;
			soundAdapter.soundTransform = soundTransform;
		}
		
		private var soundAdapter:SoundAdapter;		
	}
}