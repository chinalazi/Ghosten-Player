package com.ghosten.logger

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

/** LoggerPlugin */
class LoggerPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ServiceConnection {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity
    private var logcatService: LogcatService? = null
    private val coroutineScope = CoroutineScope(Dispatchers.Main + Job())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PLUGIN_NAMESPACE)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "logQueryPage") {
            coroutineScope.launch(Dispatchers.Main) {
                val data = withContext(Dispatchers.IO) {

                    logcatService?.queryLogPage(
                        call.argument("limit")!!,
                        call.argument<Number>("cursor")?.toLong(),
                        call.argument("filename")
                    )
                }
                result.success(data)
            }.start()
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        val intent = Intent(binding.activity.applicationContext, LogcatService::class.java)
        activity.startService(intent)
        activity.bindService(intent, this, Context.BIND_AUTO_CREATE)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        activity.unbindService(this)
    }

    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
        if (service is LogcatService.LocalBinder) {
            logcatService = service.getService()
        }
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        logcatService = null
    }

    companion object {
        const val PLUGIN_NAMESPACE = "com.ghosten.player/logger"
    }
}
