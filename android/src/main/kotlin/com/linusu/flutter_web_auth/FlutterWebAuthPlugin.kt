package com.linusu.flutter_web_auth

import android.content.Context
import android.content.Intent
import android.net.Uri

import androidx.browser.customtabs.CustomTabsIntent

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class FlutterWebAuthPlugin(private val context: Context): MethodCallHandler {
  companion object {
    val callbacks = mutableMapOf<String, Result>()

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_web_auth")
      channel.setMethodCallHandler(FlutterWebAuthPlugin(registrar.activity() ?: registrar.context()))
    }
  }

  override fun onMethodCall(call: MethodCall, resultCallback: Result) {
    when (call.method) {
        "authenticate" -> {
          val url = Uri.parse(call.argument("url"))
          val callbackUrlScheme = call.argument<String>("callbackUrlScheme")!!

          callbacks[callbackUrlScheme] = resultCallback

          val intent = CustomTabsIntent.Builder().build()
          val keepAliveIntent = Intent(context, KeepAliveService::class.java)

          intent.intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
          intent.intent.putExtra("android.support.customtabs.extra.KEEP_ALIVE", keepAliveIntent)

          intent.launchUrl(context, url)
        }
        "cleanUpDanglingCalls" -> {
          callbacks.forEach{ (_, danglingResultCallback) ->
              danglingResultCallback.error("CANCELED", "User canceled login", null)
          }
          callbacks.clear()
          resultCallback.success(null)
        }
        else -> resultCallback.notImplemented()
    }
  }
}
