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

package org.osmf.player.chrome.configuration
{
	import flash.utils.getDefinitionByName;
	
	import org.osmf.player.chrome.assets.AssetsManager;
	import org.osmf.player.chrome.widgets.*;
	
	public class WidgetsParser
	{
		public function addType(id:String, type:Class):void
		{
			widgetTypes[id.toLowerCase()] = type;
		}
		
		public function get widgets():Vector.<Widget>
		{
			return _widgets;
		}
		
		public function registerWidgetType(type:String, definition:Class):void
		{
			widgetTypes[type] = definition;
		}
		
		public function parse(widgetsList:XMLList, assetsManager:AssetsManager, parentWidget:Widget = null):void
		{
			if (parentWidget == null)
			{
				_siblings = new Vector.<Widget>();
				_widgets = new Vector.<Widget>();
			}
			
			for each (var widgetXML:XML in widgetsList)
			{
				var widget:Widget = constructWidget(widgetXML, assetsManager);
				if (parentWidget != null)
				{
					_siblings.push(widget);
					parentWidget.addChildWidget(widget);
				}
				else
				{
					_widgets.push(widget);
				}
			}
		}
		
		public function getWidget(id:String):Widget
		{
			var result:Widget;
			
			if (id != null)
			{
				var lowerCaseId:String = id.toLocaleLowerCase();
				var widget:Widget;
				
				if (_widgets != null)
				{
					for each (widget in _widgets)
					{
						if (widget.id && widget.id.toLocaleLowerCase() == lowerCaseId)
						{
							result = widget;
							break;
						}	
					}
				}
				
				if (result == null && _siblings != null)
				{
					for each (widget in _siblings)
					{
						if (widget.id && widget.id.toLocaleLowerCase() == lowerCaseId)
						{
							result = widget;
							break;
						}	
					}
				}
			}
			
			return result;
		}
		
		// Internals
		//
		
		private static const widgetTypes:Object
			=	{ alert: AlertDialog
				, button: ButtonWidget
				, qualityindicator: QualityIndicator
				, playbutton: PlayButton
				, pausebutton: PauseButton
				, mutebutton: MuteButton
				, scrubbar: ScrubBar
				, fullscreenenterbutton: FullScreenEnterButton
				, fullscreenleavebutton: FullScreenLeaveButton
				, autohidewidget: AutoHideWidget
				, authenticationdialog: AuthenticationDialog
				, label: LabelWidget
				, playlistpreviousbutton: PlaylistPreviousButton
				, playlistnextbutton: PlaylistNextButton
				};
				
		private var _widgets:Vector.<Widget>;
		private var _siblings:Vector.<Widget>;
		
		private function constructWidget(xml:XML, assetsManager:AssetsManager):Widget
		{
			var typeString:String = String(xml.@type == undefined ? "" : xml.@type).toLowerCase(); 
			var type:Class = widgetTypes[typeString]
			if (type == null)
			{
				try 
				{
					type = flash.utils.getDefinitionByName(xml.@type || "") as Class;
				}
				catch(error:Error)
				{
					if (xml.@type != undefined)
					{
						trace("WARNING: type not found", xml.@type);
					}
					type = Widget;
				}
			}
			var widget:Widget = new type();
			
			// Parse child widgets:
			parse(xml.widget, assetsManager, widget);
			
			// Configure widget:
			widget.configure(xml, assetsManager);
			
			return widget;
		}
	}	
}