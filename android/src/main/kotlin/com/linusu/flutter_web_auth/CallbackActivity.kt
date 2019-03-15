package com.linusu.flutter_web_auth

import android.app.Activity
import android.net.Uri
import android.os.Bundle

public class CallbackActivity: Activity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val url = getIntent()?.getData() as? Uri
    val scheme = url?.getScheme()

    if (scheme != null) {
      FlutterWebAuthPlugin.callbacks.remove(scheme)?.success(url.toString())
    }

    this.finish()
  }
}
