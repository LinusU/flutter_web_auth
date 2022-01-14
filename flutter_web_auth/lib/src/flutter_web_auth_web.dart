import 'dart:async';
import 'dart:convert';
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
      if (messageEvent.origin == Uri.base.origin) {
        final flutterWebAuthMessage = messageEvent.data['flutter-web-auth'];
        if (flutterWebAuthMessage is String) {
          return flutterWebAuthMessage;
        }
      }
      var appleOrigin = Uri(scheme: 'https', host: 'appleid.apple.com');
      if (messageEvent.origin == appleOrigin.toString()) {
        try {
          Map<String, dynamic> data = jsonDecode(messageEvent.data);
          if (data['method'] == 'oauthDone') {
            final appleAuth = data['data']['authorization'];
            if (appleAuth != null) {
              final appleAuthQuery = Uri(queryParameters: appleAuth).query;
              return appleOrigin.replace(fragment: appleAuthQuery).toString();
            }
          }
        } on FormatException {}
      }
    }
    throw new PlatformException(
        code: 'error', message: 'Iterable window.onMessage is empty');
  }
}
