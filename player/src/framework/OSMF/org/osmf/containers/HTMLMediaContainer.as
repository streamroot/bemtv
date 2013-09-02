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
package org.osmf.containers
{
	import flash.errors.IllegalOperationError;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	import org.osmf.elements.HTMLElement;
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.*;
	import org.osmf.utils.OSMFStrings;

	/**
	 * HTMLMediaContainer is an IMediaContainer-implementing class that uses ExternalInterface
	 * to expose the container's child media elements to JavaScript.
	 * 
	 * @includeExample HTMLMediaContainerExample.as -noswf
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class HTMLMediaContainer implements IMediaContainer
	{
		// IMediaContainer
		//

		/**
		 * @private
		 */
		public function addMediaElement(child:MediaElement):MediaElement
		{
			requireExternalInterface;
			
			if (child == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			// Find out if the element at hand is an HTML element or not:
			var htmlElement:HTMLElement = elementAsHTMLElement(child);
			
			if (htmlElement == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.UNSUPPORTED_MEDIA_ELEMENT_TYPE))
			}
			
			var result:MediaElement;
			
			var elementId:String = "element_" + elementIdCounter++;
			var elementScriptPath:String = containerScriptPath + "elements." + elementId + "."; 
			
			elements[elementId] = htmlElement;
			
			htmlElement.scriptPath = elementScriptPath; 
			
			ExternalInterface.call(containerScriptPath + "__addElement__", elementId);
			
			// Media containers are under obligation to dispatch a gateway change event when
			// they add a media element:
			child.dispatchEvent
				( new ContainerChangeEvent
					( ContainerChangeEvent.CONTAINER_CHANGE
					, false, false
					, child.container, this
					)
				);
			
			return child;
		}
		
		/**
		 * @private
		 */
		public function removeMediaElement(child:MediaElement):MediaElement
		{
			requireExternalInterface;
			
			if (child == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			
			var elementId:String = getElementId(child);
			if (elementId == null)
			{
				throw new IllegalOperationError("Element is not a child element");
			}
			
			delete elements[elementId];
			
			ExternalInterface.call
				( containerScriptPath + "__removeElement__"
				, elementId
				);
				
			// Media containers are under obigation to dispatch a gateway change event when
			// they remove a media element:
			child.dispatchEvent
				( new ContainerChangeEvent
					( ContainerChangeEvent.CONTAINER_CHANGE
					, false, false
					, child.container, null
					)
				);
			
			return child;
		}
		
		/**
		 * @private
		 */
		public function containsMediaElement(child:MediaElement):Boolean
		{
			for each (var element:HTMLElement in elements)
			{
				if (element == child)
				{
					return true;
				}
			}
			return false;
		}
		
		// Public API
		//
		
		/**
		 * Constructor.
		 * 
		 * @param containerIdentifier The identifier that will be used for this container
		 * in JavaScript. If no identifier is specified, a random one will be generated.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function HTMLMediaContainer(containerIdentifier:String = null)
		{
			_containerIdentifier
				= 	containerIdentifier
				||	( "OSMF_HTMLMediaContainer_"
					+ instanceCounter
					+ "_"
					+ Math.round(0xffffffff * Math.random())
					);
					
			initialize();
			
			instanceCounter++;
		}
		
		// Internals
		//
		
		private function initialize():void
		{
			requireExternalInterface;
			
			containerScriptPath 
				= "document.osmf.mediaContainers."
				+ ExternalInterface.objectID
				+ "_"
				+ _containerIdentifier + ".";
			
			ExternalInterface.marshallExceptions = true;
			ExternalInterface.addCallback("osmf_getProperty", getPropertyCallback);
			ExternalInterface.addCallback("osmf_setProperty", setPropertyCallback);
			ExternalInterface.addCallback("osmf_invoke", invokeCallback);
			
			ExternalInterface.call
				( registerContainer_js
				, ExternalInterface.objectID
				, _containerIdentifier
				);
		}
		
		private var elements:Dictionary = new Dictionary();
		private var elementIdCounter:int = 0;
		
		private var _containerIdentifier:String;
		private var containerScriptPath:String;
		
		private function get requireExternalInterface():*
		{
			if (ExternalInterface.available == false)
			{
				throw new IllegalOperationError("No ExternalInterface available");
			}
			
			return undefined;
		}
		
		private function getElementId(element:MediaElement):String
		{
			var result:String;
			
			for (var index:String in elements)
			{
				if (elements[index] == element)
				{
					result = index;
					break;
				} 
			}
			
			return result;
		}
		
		private function getPropertyCallback(elementId:String, property:String):*
		{
			var result:*;
			
			var element:HTMLElement = elements[elementId];
			if (element)
			{
				result = element.getPropertyCallback(property);
			}
			
			return result;
		}
		
		private function setPropertyCallback(elementId:String, property:String, value:*):void
		{
			var element:HTMLElement = elements[elementId] as HTMLElement;
			if (element)
			{
				element.setPropertyCallback(property, value);
			}
		}
		
		private function invokeCallback(elementId:String, method:String, args:Array):*
		{
			var result:*;
			
			if (elementId == null)
			{
				switch (method)
				{
					// Container
					case "trace":
						if (args.length)
						{
							trace("JavaScript says:", args[0]);
						}
						break;
					default:
						throw new IllegalOperationError
							( "Method '"
							+ method
							+ "' invoked from JavaScript is not supported on a Container."
							);
						break;
				}
			}
			else
			{
				var element:MediaElement = elements[elementId];
				if (element)
				{
					switch (method)
					{
						// Currently no methods...
						default:
							throw new IllegalOperationError
								( "Method '"
								+ method 
								+ "' invoked from JavaScript is not supported on a MediaElement."
								);
							break;
					}
				}
				else
				{
					throw new IllegalOperationError
						( "Unable to resolve the element with identifier '"
						+ elementId
						+ "' on invoking the '"
						+ method
						+ "' method from JavaScript."
						);
				}
			}
			
			return result;
		}
		
		// Utils
		//
		
		private static function elementAsHTMLElement(element:MediaElement):HTMLElement
		{
			var result:HTMLElement;
			
			if (element != null)
			{
				if (element is ProxyElement)
				{
					return arguments.callee(ProxyElement(element).proxiedElement)
				}
				else
				{
					result = element as HTMLElement;	
				}
			}
			
			return result;
		}
				
        // JavaScript API
        //
        
        private static const utils_js:XML =
        	<![CDATA[
        	function addGetter(element, property)
        	{
        		element["get" + property]
        			= function()
        				{ 
        					return element
	        					.__container__
	        					.__flashObject__
	        					.osmf_getProperty(element.elementId, property);
        				}
        	}
        	
        	function addSetter(element, property)
        	{
        		element["set" + property]
        			= function(value)
        				{ 
        					return element
	        					.__container__
	        					.__flashObject__
	        					.osmf_setProperty(element.elementId, property, value);
        				}
        	}
        	
        	function addGetSet(element, property)
        	{
        		addGetter(element, property);
        		addSetter(element, property);
        	}
        	
        	// Adds an in between function that the Flash side can invoke
        	// on signaling an event:
        	function addCallback(element, method, numArguments)
        	{
        		element["__"+method+"__"] = function()
        		{
        			var result;
        			var callback = element[method];
        			if (callback && callback.length == numArguments)
        			{
        				result = callback.apply(element, arguments) || true;
        			}
        			return result;
        		}
        	}
        	
        	// Adds a method that the JavaScript side can invoke on the 
        	// Flash side:
        	function addMethod(element, method)
        	{
        		element[method] = function()
        		{
        			element.mediaContainer.__flashObject__.osmf_invoke
    					( element.elementId
    					, method
    					, arguments.length ? arguments : []
    					);
        		}
        	}
        	
        	]]>;
        	
        private static const constants_js:XML =
        	<![CDATA[
        	function Constants()
        	{
        		this.loadState =
        			{ UNINITIALIZED: "uninitialized"
        			, LOADING: "loading"
        			, READY: "ready"
        			, UNLOADING: "unloading"
        			, LOAD_ERROR: "loadError"
        			};
        			
        		this.playState =
        			{ PLAYING: "playing"
        			, PAUSED: "paused"
        			, STOPPED: "stopped"
        			};
        	}
        	]]>;
        
        // Defines the JS Container class:
		private static const container_js:XML =
			<![CDATA[
			function Container(objectId, containerId)
        	{
        		this.containerId = containerId;
        		
        		this.__flashObject__ = document.getElementById(objectId);
        		
        		this.__addElement__ = function(elementId)
        		{
        			this.elements = this.elements || new Object();
        			
        			var element = new MediaElement(this, elementId);
        			this.elements[elementId] = element;
        			
        			if	(	this["onElementAdd"] != null
        				&&	this.onElementAdd.length == 1
        				)
        			{
        				this.onElementAdd(element);
        			}
        		}
        		
        		this.__removeElement__ = function(elementId)
        		{
        			var element = this.elements[elementId];
        			if (element == null)
        			{
        				throw "Container doesn not contain the specified element ("
        					+ elementId
        					+ ")";
        			}
        			
        			delete this.elements[elementId];
        			
        			if	(	this["onElementRemove"] != null
        				&&	this.onElementRemove.length == 1
        				)
        			{
        				this.onElementRemove(element);
        			}
        		}
        	}
        	]]>;
        
        // Defines the JS MediaElement class:
        private static const mediaElement_js:XML =
        	<![CDATA[
        	function MediaElement(container, elementId)
        	{
        		this.elementId = elementId;
        		this.__container__ = container;
        		
        		// MediaElement core properties:
        		
        		addGetter(this, "resource");
        		
        		// LoadTrait bridge: (all HTML elements are loadable)
        		
        		addSetter	(this, 	"LoadState");
        		addCallback	(this, 	"load", 1);					// urlResource
        		addCallback	(this, 	"unload", 0); 
        		
				// PlayTrait bridge:
				addGetSet	(this,	"Playable");
				addGetSet	(this, 	"CanPause");
				addGetSet	(this,	"PlayState");
				addCallback (this,	"onPlayStateChange", 1);	// newPlayState string
				
        		// TimeTrait bridge:
        		addGetSet	(this,	"Temporal");
        		addGetSet	(this,	"Duration");
        		addGetSet	(this,	"CurrentTime");
        		
        		// AudioTrait bridge:
        		
        		addGetSet	(this,	"Audible");			
        		addGetSet	(this,	"Volume");
        		addCallback	(this,	"onVolumeChange", 1);		// volume;
        		addGetSet	(this,	"Muted");
        		addCallback	(this,	"onMutedChange", 1);		// muted;
        		addGetSet	(this,	"Pan");
        		addCallback	(this,	"onPanChange", 1);			// pan;
        	}
        	]]>;
        	
        // Defines the logic that sets up the document.osmf object, adding a container:
        private static const registrationLogic_js:XML =
        	<![CDATA[
        	// Get a reference to, or otherwise construct, the document.osmf.mediaContainers path:
            var osmf 
        		= document.osmf
        		= document.osmf || {};
        		
        	osmf.constants
        		= osmf.constants || new Constants();
        		
        	var containers
        		= osmf.mediaContainers
        		= osmf.mediaContainers || {};
        
        	// For debugging, provide a 'trace' function on: it will
        	// forward the message to Flash:
        	
        	if (osmf.trace == null)
        	{
        		osmf.trace = function(message)
        		{
        			document
        				.getElementById(objectId)
        				.osmf_invoke(null, "trace", [message]);
        		}
        	}
	        	
        	// See if the container with the specified name has been registered:
        	
        	var identifier = objectId + "_" + containerId;
        	
        	if (containers[identifier] != null)
        	{
        		throw "A container by the name of "+identifier+" has already been registered."
        	}
        	else
        	{
        		var container
        			= containers[identifier]
        			= new Container(objectId, containerId);
        	}
        	
        	// Invoke "onHTMLMediaContainerConstructed"
        	if 	(	this["onHTMLMediaContainerConstructed"] != null
        		&&	this.onHTMLMediaContainerConstructed.length == 1
        		)
        	{
        		this.onHTMLMediaContainerConstructed(container);
        	}
	        
        	]]>;
		
		private static const registerContainer_js:XML = new XML
			( "<![CDATA["
			+ "function(objectId, containerId)"
			+ "{"
			+ utils_js.toString()
			+ constants_js.toString()
            + container_js.toString()
            + mediaElement_js.toString()
            + registrationLogic_js.toString()
            + "}"
            + "]]>"
            );
     	
     	private static var instanceCounter:int;
	}
}