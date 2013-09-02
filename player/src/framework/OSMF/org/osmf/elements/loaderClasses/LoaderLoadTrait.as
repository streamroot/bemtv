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
package org.osmf.elements.loaderClasses
{
	import flash.display.Loader;
	import flash.events.ProgressEvent;
	
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;
	
	[ExcludeClass]
	
	/**
	 * @private
	 **/
	public class LoaderLoadTrait extends LoadTrait
	{
		public function LoaderLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(loader, resource);
		}
		
		public function get loader():Loader
		{
			return _loader;
		}
		
		public function set loader(value:Loader):void
		{
			_loader = value;
		}
		
		override protected function loadStateChangeStart(newState:String):void
		{
			if (newState == LoadState.LOADING)
			{
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onContentLoadProgress, false, 0, true);
			}
			else if (newState == LoadState.READY)
			{
				// Update to current values.
				setBytesTotal(loader.contentLoaderInfo.bytesTotal);
				setBytesLoaded(loader.contentLoaderInfo.bytesLoaded);
				
				// But listen for any changes.
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onContentLoadProgress, false, 0, true);
			}
			else if (newState == LoadState.UNINITIALIZED)
			{
				setBytesLoaded(0);
			}
		}
		
		// Internals
		//
		
		private function onContentLoadProgress(event:ProgressEvent):void
		{
			setBytesTotal(event.bytesTotal);
			setBytesLoaded(event.bytesLoaded);
		}
		
		private var _loader:Loader;
	}
}