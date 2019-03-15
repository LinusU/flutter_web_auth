package com.linusu.flutter_web_auth

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.IBinder

public class KeepAliveService: Service() {
  companion object {
    val sBinder = Binder()
  }

  override fun onBind(intent: Intent): IBinder {
    return sBinder
  }
}
