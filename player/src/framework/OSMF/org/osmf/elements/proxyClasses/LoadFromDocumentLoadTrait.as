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
package org.osmf.elements.proxyClasses
{
	import org.osmf.events.LoadEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.LoaderBase;

	[ExcludeClass]
	
	/**
	 * @private
	 */ 
	public class LoadFromDocumentLoadTrait extends LoadTrait
	{
		/**
		 * Constructor.
		 */ 
		public function LoadFromDocumentLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(loader, resource);
		}
		
		/**
		 * @private
		 **/
		override protected function loadStateChangeEnd():void
		{
			dispatchEvent(new LoadEvent(LoadEvent.LOAD_STATE_CHANGE, false, false, loadState));
		}
		
		/**
		 * The created MediaElement.
		 */ 
		public function set mediaElement(value:MediaElement):void
		{
			_mediaElement = value;
		}
		
		public function get mediaElement():MediaElement
		{
			return _mediaElement;
		}
		
		private var _mediaElement:MediaElement;
	}
}