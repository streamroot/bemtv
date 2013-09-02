/***********************************************************
 * Copyright 2010 Adobe Systems Incorporated.  All Rights Reserved.
 *
 * *********************************************************
 * The contents of this file are subject to the Berkeley Software Distribution (BSD) Licence
 * (the "License"); you may not use this file except in
 * compliance with the License. 
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

package org.osmf.player.metadata
{
	import flash.net.NetConnection;
	CONFIG::FLASH_10_1	
	{	
		import flash.net.NetGroup;
	}
	import flash.net.NetStream;
	
	import org.osmf.net.*;
	import org.osmf.player.configuration.PlayerConfiguration;
	import org.osmf.player.media.StrobeMediaPlayer;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	
	public class MediaMetadata
	{
		public static const ID:String = "org.osmf.player.metadata.MediaMetadata";
		
		public var mediaPlayer:StrobeMediaPlayer;
		public var resourceMetadata:ResourceMetadata = new ResourceMetadata();

	}
}