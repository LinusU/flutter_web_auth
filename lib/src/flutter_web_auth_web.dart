import 'dart:async';
import 'dart:convert';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart';
import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FlutterWebAuthPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'flutter_web_auth',
      const StandardMethodCodec(),
      registrar,
    );
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
    globalContext.callMethod('open'.toJS, [url].toJSBox);
    await for (MessageEvent messageEvent in window.onMessage) {
      if (messageEvent.origin == Uri.base.origin) {
        if (messageEvent.data != null) {
          final messageEventData = messageEvent.data! as Map<dynamic, dynamic>;
          final flutterWebAuthMessage = messageEventData['flutter-web-auth'];
          if (flutterWebAuthMessage is String) {
            return flutterWebAuthMessage;
          }
        }
      }
      var appleOrigin = Uri(scheme: 'https', host: 'appleid.apple.com');
      if (messageEvent.origin == appleOrigin.toString()) {
        try {
          Map<String, dynamic> data = jsonDecode(messageEvent.data as String);
          if (data['method'] == 'oauthDone') {
            final appleAuth = data['data']['authorization'];
            if (appleAuth != null) {
              final appleAuthQuery = Uri(queryParameters: appleAuth).query;
              return appleOrigin.replace(fragment: appleAuthQuery).toString();
            }
          }
        } on Exception {}
      }
    }
    throw new PlatformException(
        code: 'error', message: 'Iterable window.onMessage is empty');
  }
}
