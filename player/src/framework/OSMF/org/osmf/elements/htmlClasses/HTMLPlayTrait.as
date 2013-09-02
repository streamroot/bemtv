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
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;

	[ExcludeClass]
	
	/**
	 * @private
	 */
	public class HTMLPlayTrait extends PlayTrait
	{
		public function HTMLPlayTrait(owner:HTMLElement)
		{
			this.owner = owner;
			
			super();
		}
		
		public function set canPause(value:Boolean):void
		{
			setCanPause(value);
		}
		
		public function set playState(value:String):void
		{
			internalMutation++;
			
			if (value != playState)
			{
				switch (value)
				{
					case PlayState.PAUSED:
						pause();
						break;
					case PlayState.STOPPED:
						stop();
						break;
					case PlayState.PLAYING:
						play();
						break;						 
				}
			}
			
			internalMutation--;
		}
		
		// Overrides
		//
		
		override protected function playStateChangeStart(newPlayState:String):void
		{
			super.playStateChangeStart(newPlayState);
			
			if (internalMutation == 0)
			{
				owner.invokeJavaScriptMethod("onPlayStateChange", newPlayState);
			}
		}
		
		// Internals
		//
		
		private var owner:HTMLElement;
		private var internalMutation:int;
	}
}