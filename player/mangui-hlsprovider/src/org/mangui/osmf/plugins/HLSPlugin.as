package org.mangui.osmf.plugins {
    import org.osmf.media.MediaElement;
    import org.osmf.media.MediaFactoryItem;
    import org.osmf.media.MediaFactoryItemType;
    import org.osmf.media.MediaResourceBase;
    import org.osmf.media.PluginInfo;

    public class HLSPlugin extends PluginInfo {
        public function HLSPlugin(items : Vector.<MediaFactoryItem>=null, elementCreationNotifFunc : Function = null) {
            items = new Vector.<MediaFactoryItem>();
            items.push(new MediaFactoryItem('org.mangui.osmf.plugins.HLSPlugin', canHandleResource, createMediaElement, MediaFactoryItemType.STANDARD));

            super(items, elementCreationNotifFunc);
        }

        private function canHandleResource(resource : MediaResourceBase) : Boolean {
            return HLSLoaderBase.canHandle(resource);
        }

        private function createMediaElement() : MediaElement {
            return new HLSLoadFromDocumentElement(null, new HLSLoaderBase());
        }
    }
}
