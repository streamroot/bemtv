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
 **********************************************************/

package org.osmf.player.chrome.assets
{
	public class SymbolResource extends AssetResource
	{
		public function SymbolResource(id:String, url:String, local:Boolean, symbol:String)
		{
			_symbol = symbol;
			
			super(id, url, local);
		}
		
		public function get symbol():String
		{
			return _symbol;
		}
		
		private var _symbol:String;
		
	}
}