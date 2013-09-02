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
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;

	/**
	 * F4MElement is a media element used to load media from F4M files.  F4M files are
	 * XML documents that adhere to the Flash Media Manifest format, and which represent
	 * all of the information needed to load and play a media file.
	 * 
	 * <p>The basic steps for creating and using an F4MElement are:
	 * <ol>
	 * <li>Create a new URLResource pointing to the URL of the F4M file.</li>
	 * <li>Create the new F4MElement, 
	 * passing the URLResource as a parameter.</li>
	 * <li>Create a new MediaPlayer.</li>
	 * <li>Assign the F4MElement to the MediaPlayer's <code>media</code> property.</li>
	 * <li>Control the media using the MediaPlayer's methods, properties, and events.</li>
	 * <li>When done with the F4MElement, set the MediaPlayer's <code>media</code>
	 * property to null.  This will unload the F4MElement.</li>
	 * </ol>
	 * </p>
	 * 
	 * <p>Note: It is simplest to use the MediaPlayer class in conjunction with the F4MElement.
	 * If you work directly with an F4MElement, then it's important to listen for events
	 * related to traits being added and removed.  If you use the MediaPlayer class with an
	 * F4MElement, then the MediaPlayer will automatically listen for these events for you.</p>
	 *
	 * @includeExample F4MElementExample.as -noswf
	 * 
	 * @see http://opensource.adobe.com/wiki/display/osmf/Flash%2BMedia%2BManifest%2BFile%2BFormat%2BSpecification Flash Media Manifest File Format Specification
	 *
	 * @see org.osmf.media.MediaPlayer
	 * @see org.osmf.media.URLResource
	 * 
 	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0	 	 	
	 */
  	public class F4MElement extends LoadFromDocumentElement
	{
		/**
		 * Constructor.
		 * 
		 * @param resource MediaResourceBase that points to the F4M file that this
		 * F4MElement will use.
		 * @param loader F4MLoader used to load the F4M file.  If null, an
		 * F4MLoader will be created by the F4MElement.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */ 
		public function F4MElement(resource:MediaResourceBase = null, loader:F4MLoader = null)
		{
			if (loader == null)
			{
				loader = new F4MLoader();
			}			
			super(resource, loader);									
		}	
	}
}