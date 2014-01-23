package org.denivip.osmf.utility.decrypt
{
	import com.hurlant.crypto.symmetric.AESKey;
	import com.hurlant.crypto.symmetric.CBCMode;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.IPad;
	import com.hurlant.crypto.symmetric.IVMode;
	import com.hurlant.crypto.symmetric.NullPad;
	import com.hurlant.crypto.symmetric.PKCS5;
	
	import flash.utils.ByteArray;
	
	/**
	 * Contains Utility functions for Decryption
	 */
	public class AES
	{
		private var _key:AESKey;
		private var _mode:ICipher;
		private var _iv:ByteArray;
		
		public function AES(key:ByteArray) {
			_key = new AESKey(key);
		}
		
		public function set pad(type:String):void {
			var pad:IPad;
			if (type == "pkcs7") {
				pad = new PKCS5;
			} else {
				pad = new NullPad;
			}
			_mode = new CBCMode(_key, pad);
			pad.setBlockSize(_mode.getBlockSize());
			// Reset IV if it was already set
			if (_iv) {
				this.iv = _iv;
			}
		}
		
		public function set iv(iv:ByteArray):void {
			_iv = iv;
			if (_mode) {
				if (_mode is IVMode) {
					var ivmode:IVMode = _mode as IVMode;
					ivmode.IV = iv;
				}
			}
		}
		
		public function decrypt(data:ByteArray):ByteArray {
			_mode.decrypt(data);
			return data;
		}
		
		public function destroy():void {
			_key = null;
			_mode = null;
		}
	}
	
}
