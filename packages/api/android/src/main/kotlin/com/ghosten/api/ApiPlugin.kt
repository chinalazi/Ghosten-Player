package com.ghosten.api

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.io.IOException
import java.net.InetAddress
import java.net.NetworkInterface
import java.util.*

class ApiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ServiceConnection {
    private lateinit var channel: MethodChannel
    private lateinit var binaryMessenger: BinaryMessenger
    private lateinit var activity: Activity
    private var apiService: ApiService? = null
    private val eventSinkMap: MutableMap<String, EventChannel.EventSink> = mutableMapOf()
    private var methodCallResult: Result? = null
    private var serviceConnected = false
    private val coroutineScope = CoroutineScope(Dispatchers.Main + Job())

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, PLUGIN_NAMESPACE)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getLocalIpAddress" -> result.success(getLocalIpAddress())
            "databasePath" -> result.success(apiService?.databasePath?.path)
            "initialized" -> {
                if (serviceConnected) {
                    result.success(apiService?.apiInitializedPort())
                } else {
                    methodCallResult = result
                }
            }

            else -> {
                if (apiService == null) {
                    return result.error("50000", "Service Start Failed", null)
                }
                coroutineScope.launch(Dispatchers.Main) {
                    if (call.method.endsWith("/cb")) {
                        val id = UUID.randomUUID().toString()
                        result.success(byteArrayOf(217.toByte(), 36).plus(id.toByteArray()))
                        val eventChannel =
                            EventChannel(binaryMessenger, "$PLUGIN_NAMESPACE/update/$id")
                        var finished = false
                        var apiException: ApiException? = null
                        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
                            override fun onListen(args: Any?, eventSink: EventChannel.EventSink?) {
                                if (eventSink != null) {
                                    if (finished) {
                                        if (apiException != null) {
                                            result.error(
                                                apiException!!.code.toString(),
                                                apiException!!.message,
                                                null
                                            )
                                        }
                                        eventSink.endOfStream()
                                    } else {
                                        eventSinkMap[id] = eventSink
                                    }
                                }
                            }

                            override fun onCancel(args: Any?) {
                                eventSinkMap.remove(id)?.endOfStream()
                            }
                        })

                        try {
                            withContext(Dispatchers.IO) {
                                apiService?.apiCallWithCallback(
                                    call.method,
                                    call.argument<ByteArray>("data")!!,
                                    call.argument<ByteArray>("params")!!,
                                    object : ApiMethodHandler {
                                        override fun onApiMethodUpdate(data: ByteArray) {
                                            activity.runOnUiThread {
                                                eventSinkMap[id]?.success(
                                                    data.copyOfRange(
                                                        2,
                                                        data.size
                                                    )
                                                )
                                            }
                                        }
                                    })
                            }
                        } catch (ex: ApiException) {
                            if (eventSinkMap[id] != null) {
                                eventSinkMap[id]?.error(
                                    ex.code.toString(),
                                    ex.message,
                                    null
                                )
                            } else {
                                apiException = ex
                            }
                        } finally {
                            eventSinkMap.remove(id)?.endOfStream()
                        }
                        finished = true
                    } else {
                        try {
                            val data = withContext(Dispatchers.IO) {
                                apiService!!.apiCall(
                                    call.method,
                                    call.argument<ByteArray>("data")!!,
                                    call.argument<ByteArray>("params")!!,
                                )
                            }
                            result.success(data)

                        } catch (ex: ApiException) {
                            result.error(ex.code.toString(), ex.message, null)
                        }
                    }
                }.start()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        val intent = Intent(binding.activity.applicationContext, ApiService::class.java)
        activity.startService(intent)
        activity.bindService(intent, this, Context.BIND_AUTO_CREATE)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        activity.unbindService(this)
    }

    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
        if (service is ApiService.LocalBinder) {
            apiService = service.getService()
            serviceConnected = true
            methodCallResult?.success(apiService?.apiInitializedPort())
            methodCallResult = null
        }
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        serviceConnected = false
        apiService = null
    }

    private fun getLocalIpAddress(): String? {
        val interfaces = Collections.list(NetworkInterface.getNetworkInterfaces())
        for (intf in interfaces) {
            val addrs = Collections.list(intf.inetAddresses)
            for (addr in addrs) {
                if (!addr.isLoopbackAddress && addr is InetAddress) {
                    val sAddr = addr.hostAddress
                    if (sAddr != null && sAddr.indexOf(':') < 0) {
                        return sAddr
                    }
                }
            }
        }
        return null
    }

    companion object {
        const val PLUGIN_NAMESPACE = "com.ghosten.player/api"
        const val TAG = "API Error"
    }
}
