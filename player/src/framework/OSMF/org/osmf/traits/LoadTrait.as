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
package org.osmf.traits
{
	import flash.errors.IllegalOperationError;
	
	import org.osmf.events.LoadEvent;
	import org.osmf.events.LoaderEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.utils.OSMFStrings;

	/**
	 * Dispatched when the state of the LoadTrait has changed.
	 *
	 * @eventType org.osmf.events.LoadEvent.LOAD_STATE_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="loadStateChange", type="org.osmf.events.LoadEvent")]

	/**
	 * Dispatched when total size in bytes of data being loaded has changed.
	 * 
	 * @eventType org.osmf.events.LoadEvent.BYTES_TOTAL_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	[Event(name="bytesTotalChange",type="org.osmf.events.LoadEvent")]

	/**
	 * LoadTrait defines the trait interface for media that must be loaded before it
	 * can be presented.  It can also be used as the base class for a more specific
	 * LoadTrait subclass.
	 * 
	 * <p>If <code>hasTrait(MediaTraitType.LOAD)</code> returns <code>true</code>,
	 * use the <code>MediaElement.getTrait(MediaTraitType.LOAD)</code> method
	 * to get an object of this type.</p>
	 * 
	 * @see LoadState
	 * @see org.osmf.media.MediaElement
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class LoadTrait extends MediaTraitBase
	{
		/**
		 * Constructor.
		 * 
		 * @param loader The LoaderBase instance that will be used to load the
		 * media for the media element that owns this trait.
		 * @param resource The MediaResourceBase instance that represents the media resource 
		 * to be loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		public function LoadTrait(loader:LoaderBase, resource:MediaResourceBase)
		{
			super(MediaTraitType.LOAD);
			
			this.loader = loader;			
			_resource = resource;
			_loadState = LoadState.UNINITIALIZED;
			
			if (loader != null)
			{
				// We set the highest possible priority to ensure that our handler
				// is the first to process the loader's event.  The reason for this
				// is to ensure that clients that work with both a loader and a
				// LoadTrait always perceive a consistent state between the two (which
				// could be subverted if the loader updates its state, then the client
				// gets the event, then the LoadTrait updates its state).
				loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE, onLoadStateChange, false, int.MAX_VALUE, true);
			}
		}
		
		/**
		 * Resource representing the piece of media to be loaded into
		 * this LoadTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get resource():MediaResourceBase
		{
			return _resource;
		}
		
		/**
		 * The load state of this trait.  See LoadState for possible values.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get loadState():String
		{
			return _loadState;
		}
				
		/**
		 * Loads this the media into this LoadTrait.
		 * Updates the load state.
         * Dispatches the <code>loadStateChange</code> event with every state change.
         *
         * <p>Typical states are <code>LOADING</code> while the media is loading,
         * <code>READY</code> after it has successfully completed loading, 
         * and <code>LOAD_ERROR</code> if it fails to complete loading.</p>
		 * 
         * <p>If the LoadState is <code>LOADING</code> or <code>READY</code>
         * when the method is called, throws an error.</p>
         *  
         * @see LoadState
		 * @throws IllegalOperationError If this trait is unable to load
		 * itself or if the LoadState is <code>LOADING</code> or
         * <code>READY</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function load():void
		{
			if (loader)
			{	
				if (_loadState == LoadState.READY)
				{
					throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_READY));
				}
				if (_loadState == LoadState.LOADING)
				{
					throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_LOADING));
				}
				else
				{
					loader.load(this);
				}
			}
			else
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.MUST_SET_LOADER));
			}
		}
		
		/**
         * Unloads this LoadTrait. Updates the load state.
         * Dispatches the <code>loadStateChange</code> event with every state change.
		 * 
         * <p>Typical states are <code>UNLOADING</code> while the media is unloading,
         * <code>UNINITIALIZED</code> after it has successfully completed unloading, 
         * and <code>LOAD_ERROR</code> if it fails to complete unloading.</p>
		 * 
 		 * <p>If the LoadState is not <code>READY</code> when the
 		 * method is called, throws an error.</p>
		 * 
		 * @param loadTrait The LoadTrait to unload.
         * @see LoadState
		 * 
		 * @throws IllegalOperationError If this trait is unable to unload
		 * itself, or if the LoadState is not <code>READY</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function unload():void
		{
			if (loader)
			{	
				if (_loadState == LoadState.UNLOADING)
				{
					throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_UNLOADING));
				}
				if (_loadState == LoadState.UNINITIALIZED)
				{
					throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_UNLOADED));
				}
				loader.unload(this);
			}
			else
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.MUST_SET_LOADER));
			}
		}
		
		/**
		 * The number of bytes of data that have been loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function get bytesLoaded():Number
		{
			return _bytesLoaded;
		}
		
		/**
		 * The total size in bytes of the data being loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */	
		public function get bytesTotal():Number
		{
			return _bytesTotal;
		}
		
		// Internals
		//
		
		/**
		 * Sets the load state for this LoadTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected final function setLoadState(newState:String):void
		{
			if (_loadState != newState)
			{
				loadStateChangeStart(newState);
				
				_loadState = newState;
				
				loadStateChangeEnd();				
			}
		}
		
		/**
		 * Sets the number of bytes of data that have been loaded.
		 *  
		 * @throws ArgumentError If value is negative, NaN, or greater than bytesTotal.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected final function setBytesLoaded(value:Number):void
		{
			if (isNaN(value) || value > bytesTotal || value < 0)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			if (value != _bytesLoaded)
			{
				bytesLoadedChangeStart(value);
				
				_bytesLoaded = value;
				
				bytesLoadedChangeEnd();
			}
		}
		
		/**
		 * Sets the total size in bytes of the data being loaded.
		 *  
		 * @throws ArgumentError If value is negative or smaller than bytesLoaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected final function setBytesTotal(value:Number):void
		{
			if (value < _bytesLoaded || value < 0)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}

			if (value != _bytesTotal)
			{
				bytesTotalChangeStart(value);
				
				_bytesTotal = value;
				
				bytesTotalChangeEnd();
			}
		}
		
		/**
		 * Called immediately before the <code>bytesLoaded</code> property is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
		 *  
		 * @param newValue New <code>bytesLoaded</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function bytesLoadedChangeStart(newValue:Number):void
		{
		}

		/**
		 * Called just after the <code>bytesLoaded</code> property has changed.
		 * 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function bytesLoadedChangeEnd():void
		{
		}

		/**
		 * Called immediately before the <code>bytesTotal</code> property is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
		 *  
		 * @param newValue New <code>bytesTotal</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function bytesTotalChangeStart(newValue:Number):void
		{
		}
		
		/**
		 * Called just after the <code>bytesTotal</code> property has changed.
		 * Dispatches the bytesTotalChange event.
		 * <p>Subclasses that override should call this method to
		 * dispatch the bytesTotalChange event.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function bytesTotalChangeEnd():void
		{
			dispatchEvent(new LoadEvent(LoadEvent.BYTES_TOTAL_CHANGE, false, false, null, _bytesTotal));
		}

		/**
		 * Called immediately before the <code>loadState</code>
		 * property is changed.
		 * <p>Subclasses can override this method to communicate the change to the media.</p>
		 *  
		 * @param newState New <code>loadState</code> value.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function loadStateChangeStart(newState:String):void
		{
		}
		
		/**
		 * Called just after the <code>loadState</code> property is
		 * change.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */		
		protected function loadStateChangeEnd():void
		{
			dispatchEvent(new LoadEvent(LoadEvent.LOAD_STATE_CHANGE, false, false, _loadState));
		}
		
		private function onLoadStateChange(event:LoaderEvent):void
		{
			if (event.loadTrait == this)
			{
				setLoadState(event.newState);
			}
		}

		private var loader:LoaderBase;
		private var _resource:MediaResourceBase;
		
		private var _loadState:String;

		private var _bytesLoaded:Number;
		private var _bytesTotal:Number;
	}
}