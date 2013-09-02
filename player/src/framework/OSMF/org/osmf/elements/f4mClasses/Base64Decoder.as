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
package org.osmf.elements.f4mClasses
{
	import flash.utils.ByteArray;
	
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * A utility class to decode a Base64 encoded String to a ByteArray.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	internal class Base64Decoder
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
	    /**
	     * Constructor.
	     *  
	     *  @langversion 3.0
	     *  @playerversion Flash 10
	     *  @playerversion AIR 1.5
	     *  @productversion OSMF 1.0
	     */
	    public function Base64Decoder()
	    {
	        super();
	        data = new ByteArray();
	    }
	
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
	
	    /**
	     * Decodes a Base64 encoded String and adds the result to an internal
	     * buffer. Subsequent calls to this method add on to the internal
	     * buffer. After all data have been encoded, call <code>drain()</code>
	     * to obtain a decoded <code>flash.utils.ByteArray</code>.
	     * 
	     * @param encoded The Base64 encoded String to decode.
	     *  
	     *  @langversion 3.0
	     *  @playerversion Flash 10
	     *  @playerversion AIR 1.5
	     *  @productversion OSMF 1.0
	     */
	    public function decode(encoded:String):void
	    {
	        for (var i:uint = 0; i < encoded.length; ++i)
	        {
	            var c:Number = encoded.charCodeAt(i);
	
	            if (c == ESCAPE_CHAR_CODE)
	                work[count++] = -1;
	            else if (inverse[c] != 64)
	                work[count++] = inverse[c];
	            else
	                continue;
	
	            if (count == 4)
	            {
	                count = 0;
	                data.writeByte((work[0] << 2) | ((work[1] & 0xFF) >> 4));
	                filled++;
	
	                if (work[2] == -1)
	                    break;
	
	                data.writeByte((work[1] << 4) | ((work[2] & 0xFF) >> 2));
	                filled++;
	
	                if (work[3] == -1)
	                    break;
	
	                data.writeByte((work[2] << 6) | work[3]);
	                filled++;
	            }
	        }
	    }
	
	    /**
	     * @private
	     */
	    public function drain():ByteArray
	    {
	        var result:ByteArray = new ByteArray();
	        copyByteArray(data, result, filled);
	        filled = 0;
	        return result;
	    }
	
		//--------------------------------------------------------------------------
		//
		//  Private Methods
		//
		//--------------------------------------------------------------------------
	
	    private static function copyByteArray(source:ByteArray, destination:ByteArray, length:uint = 0):void
	    {
	        var oldPosition:int = source.position;
	
	        source.position = 0;
	        destination.position = 0;
	        var i:uint = 0;
	
	        while (source.bytesAvailable > 0 && i < length)
	        {
	            destination.writeByte(source.readByte());
	            i++;
	        }
	
	        source.position = oldPosition;
	        destination.position = 0;
	    }
	
		//--------------------------------------------------------------------------
		//
		//  Private Variables
		//
		//--------------------------------------------------------------------------
	
	    private var count:int = 0;
	    private var data:ByteArray;
	    private var filled:int = 0;
	    private var work:Array = [0, 0, 0, 0];
	
	   	
	    private static const ESCAPE_CHAR_CODE:Number = 61; // The '=' char
	
	    private static const inverse:Array =
	    [
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63,
	        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64,
	        64, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
	        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64,
	        64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64,
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
	        64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64
	    ];
	}
	
}