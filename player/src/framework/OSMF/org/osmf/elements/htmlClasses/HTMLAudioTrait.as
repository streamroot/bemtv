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
package org.osmf.elements.htmlClasses
{
	import org.osmf.elements.HTMLElement;
	import org.osmf.traits.AudioTrait;

	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class HTMLAudioTrait extends AudioTrait
	{
		public function HTMLAudioTrait(owner:HTMLElement)
		{
			this.owner = owner;
			
			super();
		}
		
		public function setVolume(value:Number):void
		{
			internalMutation++;
			
			volume = value;
			
			internalMutation--;	
		}
		
		public function setMuted(value:Boolean):void
		{
			internalMutation++;
			
			muted = value;
			
			internalMutation--;
		}
		
		public function setPan(value:Number):void
		{
			internalMutation++;
			
			pan = value;
			
			internalMutation--;
		}
		
		// Overrides
		//
		
		override protected function volumeChangeStart(newVolume:Number):void
		{
			super.volumeChangeStart(newVolume);
			
			if (internalMutation == 0)
			{
				owner.invokeJavaScriptMethod("onVolumeChange", newVolume);
			}
		} 
		
		override protected function mutedChangeStart(newMuted:Boolean):void
		{
			super.mutedChangeStart(newMuted);
			
			if (internalMutation == 0)
			{
				owner.invokeJavaScriptMethod("onMutedChange", newMuted);
			}
		}
		
		override protected function panChangeStart(newPan:Number):void
		{
			super.panChangeStart(newPan);
			
			if (internalMutation == 0)
			{
				owner.invokeJavaScriptMethod("onPanChange", newPan);
			}
		}
		
		// Internals
		//
		
		private var owner:HTMLElement;
		private var internalMutation:int;	
	}
}