import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FlutterWebAuthPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
        'flutter_web_auth', const StandardMethodCodec(), registrar.messenger);
    final FlutterWebAuthPlugin instance = FlutterWebAuthPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'authenticate':
        final String url = call.arguments['url'];
        return _authenticate(url);
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The flutter_web_auth plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }

  static Future<String> _authenticate(String url) async {
    context.callMethod('open', [url]);
    await for (MessageEvent messageEvent in window.onMessage) {
      final message = messageEvent.data['flutter-web-auth'];
      if (messageEvent.origin == Uri.base.origin && message is String) {
        return message;
      }
    }
    throw new PlatformException(
        code: 'error', message: 'Iterable window.onMessage is empty');
  }
}
