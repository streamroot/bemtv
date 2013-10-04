package org.denivip.osmf.elements
{
	import org.osmf.elements.LoadFromDocumentElement;
	import org.osmf.media.MediaResourceBase;
	
	/**
	 * Media element for playlist loading
	 */
	public class M3U8Element extends LoadFromDocumentElement
	{
		public function M3U8Element(resource:MediaResourceBase=null, loader:M3U8Loader=null)
		{
			if(loader == null){
				loader = new M3U8Loader();
			}
			super(resource, loader);
		}
	}
}