package dev.shovel.flutter_plugin_webview

import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

class WebviewState {
    companion object {
        fun onStateChange(channel: MethodChannel, data: HashMap<String, Any>, isIdleAfter: Boolean = true, callback: MethodChannel.Result? = null) {
            if (callback != null) {
                channel.invokeMethod("onStateChange", data, callback)
            } else {
                channel.invokeMethod("onStateChange", data)
            }
            if (isIdleAfter) {
                onStateIdle(channel)
            }
        }

        fun onStateIdle(channel: MethodChannel) {
            val data = HashMap<String, Any>()
            data["event"] = "idle"
            channel.invokeMethod("onStateChange", data)
        }
    }
}