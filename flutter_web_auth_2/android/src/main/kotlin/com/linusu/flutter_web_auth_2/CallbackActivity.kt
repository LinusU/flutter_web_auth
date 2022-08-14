package com.linusu.flutter_web_auth_2

import android.app.Activity
import android.net.Uri
import android.os.Bundle

class CallbackActivity: Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val url = intent?.data
    val scheme = url?.scheme

    if (scheme != null) {
      FlutterWebAuth2Plugin.callbacks.remove(scheme)?.success(url.toString())
    }

    finish()
  }
}
