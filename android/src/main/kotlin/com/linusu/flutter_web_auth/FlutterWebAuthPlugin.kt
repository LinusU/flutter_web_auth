package com.linusu.flutter_web_auth

import java.util.HashMap

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
    public val callbacks = HashMap<String, Result>()

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_web_auth")
      channel.setMethodCallHandler(FlutterWebAuthPlugin(registrar.activity() ?: registrar.context()))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "authenticate") {
      val url = Uri.parse(call.argument<String>("url"))
      val callbackUrlScheme = call.argument<String>("callbackUrlScheme")!!

      callbacks.put(callbackUrlScheme, result)

      val intent = CustomTabsIntent.Builder().build()
      val keepAliveIntent = Intent().setClassName(context.getPackageName(), KeepAliveService::class.java.canonicalName)

      intent.intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
      intent.intent.putExtra("android.support.customtabs.extra.KEEP_ALIVE", keepAliveIntent)

      intent.launchUrl(context, url)
    } else {
      result.notImplemented()
    }
  }
}
