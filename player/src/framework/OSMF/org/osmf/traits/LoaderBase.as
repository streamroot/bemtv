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
	import flash.events.EventDispatcher;
	
	import org.osmf.events.LoaderEvent;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * Dispatched when the state of a LoadTrait being loaded or unloaded by
	 * the LoaderBase has changed.
	 *
	 * @eventType org.osmf.events.LoaderEvent.LOAD_STATE_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	[Event(name="loadStateChange", type="org.osmf.events.LoaderEvent")]
	
	/**
	 * LoaderBase is the base class for objects that are capable of loading
	 * and unloading LoadTraits.
	 * 
	 * <p>A MediaElement that has the LoadTrait uses a LoaderBase to perform the
	 * actual load operation.
	 * This decoupling of the loading and unloading from the media allows a 
	 * MediaElement to use different loaders for different circumstances.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */	
	public class LoaderBase extends EventDispatcher
	{
		/**
		 * Indicates whether this loader is capable of handling (loading)
		 * the given MediaResourceBase.
		 * 
		 * @param resource The media resource in question.
		 * 
		 * @return True if this loader can handle the given resource.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function canHandleResource(resource:MediaResourceBase):Boolean
		{
			return false;
		}

		/**
         * Loads the specified LoadTrait. Changes the load state of the LoadTrait.
         * Dispatches the <code>loadStateChange</code> event with every state change.
		 * 
         * <p>Typical states are <code>LOADING</code> while the LoadTrait is loading,
         * <code>READY</code> after it has successfully completed loading, 
         * and <code>LOAD_ERROR</code> if it fails to complete loading.</p>
         * 
         * <p>If the LoadTrait's LoadState is <code>LOADING</code> or
         * <code>READY</code> when the method is called, this method throws
         * an error.</p>
         * 
         * <p>Subclasses should override the <code>executeLoad</code> method to perform
         * the actual load operation.</p>
         * 
         * @see org.osmf.traits.LoadState
		 * 
		 * @param loadTrait The LoadTrait to load.
		 * 
		 * @throws IllegalOperationError <code>IllegalOperationError</code>
		 * If this loader cannot load the given LoadTrait (as determined by
         * the <code>canHandleResource()</code> method),
         * or if the LoadTrait's LoadState is <code>LOADING</code> or
         * <code>READY</code>.
  		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public final function load(loadTrait:LoadTrait):void
		{
			validateLoad(loadTrait);
			executeLoad(loadTrait);
		}
		
		/**
         * Unloads the specified LoadTrait. Changes the load state of the LoadTrait.
         * Dispatches the <code>loaderStateChange</code> event with every state change.
		 * 
         * <p>Typical states are <code>UNLOADING</code> while the LoadTrait is unloading,
         * <code>UNINITIALIZED</code> after it has successfully completed unloading, 
         * and <code>LOAD_ERROR</code> if it fails to complete unloading.</p>
         * 
         * <p>If the LoadTrait's LoadState is not <code>READY</code> when the method
         * is called, this method throws an error.</p>
         * 
         * <p>Subclasses should override the <code>executeUnload</code> method to perform
         * the actual unload operation.</p>
         * 
         * @see org.osmf.traits.LoadState
		 * 
		 * @param loadTrait The LoadTrait to unload.
		 * 
		 * @throws IllegalOperationError <code>IllegalOperationError</code>
		 * If this loader cannot unload the specified LoadTrait (as determined by
         * the <code>canHandleResource()</code> method),
         * or if the LoadTrait's LoadState is not <code>READY</code>.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public final function unload(loadTrait:LoadTrait):void
		{
			validateUnload(loadTrait);
			executeUnload(loadTrait);
		}
				
		// Protected
		
		/**
		 * Executes the load of the given LoadTrait.
		 * 
		 * <p>This method is invoked by <code>load()</code>.
		 * Subclasses should override this method to provide their
		 * own implementation of the load operation.</p>
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function executeLoad(loadTrait:LoadTrait):void
		{
		}

		/**
		 * Executes the unload of the given LoadTrait.
		 * 
		 * <p>This method is invoked by <code>unload()</code>.
		 * Subclasses should override this method to provide their
		 * own implementation of the unload operation.</p>
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function executeUnload(loadTrait:LoadTrait):void
		{
		}
		
		/**
		 * Updates the given LoadTrait with the given info, and dispatches the
		 * state change event if necessary.
		 * 
		 * @param loadTrait The LoadTrait to update.
		 * @param newState The new LoadState of the LoadTrait.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected final function updateLoadTrait(loadTrait:LoadTrait, newState:String):void
		{
			if (newState != loadTrait.loadState)
			{
				var oldState:String = loadTrait.loadState;
				
				dispatchEvent
					( new LoaderEvent
						( LoaderEvent.LOAD_STATE_CHANGE
						, false
						, false
						, this
						, loadTrait
						, oldState
						, newState
						)
					);
			}
		}
		
		/**
		 * Validates that the given LoadTrait can be loaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function validateLoad(loadTrait:LoadTrait):void
		{
			if (loadTrait == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			if (loadTrait.loadState == LoadState.READY)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_READY));
			}
			if (loadTrait.loadState == LoadState.LOADING)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_LOADING));
			}
			if (canHandleResource(loadTrait.resource) == false)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.LOADER_CANT_HANDLE_RESOURCE));
			}
		}

		
		/**
		 * Validates that the given LoadTrait can be unloaded.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		private function validateUnload(loadTrait:LoadTrait):void
		{
			if (loadTrait == null)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
			}
			if (loadTrait.loadState == LoadState.UNLOADING)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_UNLOADING));
			}
			if (loadTrait.loadState == LoadState.UNINITIALIZED)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_UNLOADED));
			}
			if (canHandleResource(loadTrait.resource) == false)
			{
				throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.LOADER_CANT_HANDLE_RESOURCE));
			}
		}
	}
}