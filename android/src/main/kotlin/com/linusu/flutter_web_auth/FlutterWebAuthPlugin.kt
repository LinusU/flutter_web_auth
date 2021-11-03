package com.linusu.flutter_web_auth

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log
import androidx.browser.customtabs.CustomTabsIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class FlutterWebAuthPlugin(
    private var channel: MethodChannel? = null,
    private var activityBinding: ActivityPluginBinding? = null
) : MethodCallHandler, FlutterPlugin, ActivityAware, PluginRegistry.NewIntentListener {

    private lateinit var lifecycleListener: ActivityLifecycleListener

    private val activity: Activity
        get() = activityBinding!!.activity

    companion object {
        val callbacks = mutableMapOf<String, Result>()
    }

    private fun initInstance(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, "flutter_web_auth")
        channel?.setMethodCallHandler(this)
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        initInstance(binding.binaryMessenger)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding.apply {
            addOnNewIntentListener(this@FlutterWebAuthPlugin)
            lifecycleListener = ActivityLifecycleListener(activity.javaClass.name) {
                cleanUpDanglingCalls()
            }
            activity.application.registerActivityLifecycleCallbacks(lifecycleListener)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.apply {
            removeOnNewIntentListener(this@FlutterWebAuthPlugin)
            activity.application.unregisterActivityLifecycleCallbacks(lifecycleListener)
        }
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding.apply {
            addOnNewIntentListener(this@FlutterWebAuthPlugin)
            activity.application.registerActivityLifecycleCallbacks(lifecycleListener)
        }
    }

    override fun onDetachedFromActivity() {
        activityBinding?.apply {
            removeOnNewIntentListener(this@FlutterWebAuthPlugin)
            activity.application.unregisterActivityLifecycleCallbacks(lifecycleListener)
        }
        activityBinding = null
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = null
    }

    override fun onMethodCall(call: MethodCall, resultCallback: Result) {
        when (call.method) {
            "authenticate" -> {
                val url = Uri.parse(call.argument("url"))
                val callbackUrlScheme = call.argument<String>("callbackUrlScheme")!!
                val preferEphemeral = call.argument<Boolean>("preferEphemeral")!!

                callbacks[callbackUrlScheme] = resultCallback

                val intent = CustomTabsIntent.Builder().build()
                val keepAliveIntent = Intent(activity, KeepAliveService::class.java)

                intent.intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
                if (preferEphemeral) {
                    intent.intent.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
                }
                intent.intent.putExtra(
                    "android.support.customtabs.extra.KEEP_ALIVE",
                    keepAliveIntent
                )
                intent.intent.data = url
                intent.launchUrl(activity, url)
            }
            else -> resultCallback.notImplemented()
        }
    }

    private fun cleanUpDanglingCalls() {
        if (callbacks.isNotEmpty()) {
            callbacks.forEach { (_, danglingResultCallback) ->
                danglingResultCallback.error("CANCELED", "User canceled login", null)
            }
            callbacks.clear()
        }
    }

    override fun onNewIntent(intent: Intent?): Boolean {
        if (intent != null && intent.action == Intent.ACTION_VIEW &&
            intent.hasCategory(Intent.CATEGORY_BROWSABLE)
        ) {
            val url = intent.data
            val scheme = url?.scheme
            callbacks.remove(scheme)?.success(url?.toString())
            return true
        }
        return false
    }
}

private class ActivityLifecycleListener(
    val appActivityName: String,
    val onReturnFromBrowser: () -> Unit
) : Application.ActivityLifecycleCallbacks {

    var paused: Boolean = false

    override fun onActivityPaused(activity: Activity) {
        verifyActivity(activity) {
            paused = true
        }
    }

    override fun onActivityResumed(activity: Activity) {
        verifyActivity(activity) {
            if (paused) {
                Log.d("FlutterWebAuthPlugin", "onReturnFromBrowser")
                onReturnFromBrowser()
                paused = false
            }
        }
    }

    fun verifyActivity(activity: Activity, success: () -> Unit) {
        if (activity.javaClass.name == appActivityName && activity is FlutterActivity) {
            success()
        }
    }

    override fun onActivityCreated(activity: Activity?, savedInstanceState: Bundle?) {}

    override fun onActivityStarted(activity: Activity) {}

    override fun onActivitySaveInstanceState(activity: Activity?, outState: Bundle?) {}

    override fun onActivityStopped(activity: Activity?) {}

    override fun onActivityDestroyed(activity: Activity?) {}
}