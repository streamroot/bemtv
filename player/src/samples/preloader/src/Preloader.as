/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 *  The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 *  (the "License"); you may not use this file except in
 *  compliance with the License. 
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 *
 * The Initial Developer of the Original Code is Adobe Systems Incorporated.
 * Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe Systems
 * Incorporated. All Rights Reserved.
 * 
 **********************************************************/

package
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	
	/**
	 * Example Preloader which demonstrates the use of the plugin host whitelist feature of the Plugin Loader.
	 * 
	 * Use [Frame(extraClass="StrobeMediaPlayback")] to force the compiler to compile StrobeMediaPlayback too. 
	 */	
	[Frame(extraClass="StrobeMediaPlayback")]
	public class Preloader extends Sprite
	{
		public function Preloader()
		{
			var playerClass:Class = getDefinitionByName("StrobeMediaPlayback") as Class;
			var playerInstance:Object = new playerClass();
			playerInstance.initialize(loaderInfo.parameters, stage, loaderInfo, pluginHostWhitelist);			
			addChild(playerInstance as DisplayObject);
		}
		
		/** Sample plugin host white-list. Strobe Media Playback will load plugins originating only from these hosts or the host hosting the plugin. */
		
		private static const pluginHostWhitelist:Array = ["adobe.com", "fpdownloads.adobe.com"];
	}
}