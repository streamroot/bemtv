package org.mangui.HLS.utils {
    import flash.geom.Rectangle;

    public class ScaleVideo {
        public static function resizeRectangle(videoWidth : Number, videoHeight : Number, containerWidth : Number, containerHeight : Number) : Rectangle {
            var rect : Rectangle = new Rectangle();
            var xscale : Number = containerWidth / videoWidth;
            var yscale : Number = containerHeight / videoHeight;
            if (xscale >= yscale) {
                rect.width = Math.min(videoWidth * yscale, containerWidth);
                rect.height = videoHeight * yscale;
            } else {
                rect.width = Math.min(videoWidth * xscale, containerWidth);
                rect.height = videoHeight * xscale;
            }
            rect.width = Math.ceil(rect.width);
            rect.height = Math.ceil(rect.height);
            rect.x = Math.round((containerWidth - rect.width) / 2);
            rect.y = Math.round((containerHeight - rect.height) / 2);
            Log.debug("width:" + rect.width);
            Log.debug("height:" + rect.height);
            Log.debug("x:" + rect.x);
            Log.debug("y:" + rect.y);
            return rect;
        }
    }
}
