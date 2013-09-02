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
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	[ExcludeClass]
	
	/**
	 * @private
	 **/
	public class AudioSeekTrait extends SeekTrait
	{
		public function AudioSeekTrait(timeTrait:TimeTrait, soundAdapter:SoundAdapter)
		{
			super(timeTrait);
			
			this.soundAdapter = soundAdapter;
		}

		/** 
		 * @private
		 */
		override protected function seekingChangeStart(newSeeking:Boolean, time:Number):void
		{
			if (newSeeking)
			{
				soundAdapter.seek(time);	
			}					
		}
		
		/** 
		 * @private
		 */
		override protected function seekingChangeEnd(time:Number):void
		{
			super.seekingChangeEnd(time);
			
			// If we just started seeking, finish since this operation is async.
			if (seeking == true)
			{
				setSeeking(false, time);
			}
		}
			
		private var soundAdapter:SoundAdapter;
	}
}