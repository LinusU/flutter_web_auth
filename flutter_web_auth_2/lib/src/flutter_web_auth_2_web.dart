import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:js';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class FlutterWebAuth2WebPlugin extends FlutterWebAuth2Platform {
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'flutter_web_auth_2',
      const StandardMethodCodec(),
      registrar,
    );
    final instance = FlutterWebAuth2WebPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
    FlutterWebAuth2Platform.instance = instance;
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'authenticate':
        final url = call.arguments['url'].toString();
        return authenticate(
          url: url,
          callbackUrlScheme: '',
          preferEphemeral: false,
        );
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The flutter_web_auth_2 plugin for web doesn't implement "
              "the method '${call.method}'",
        );
    }
  }

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required bool preferEphemeral,
  }) async {
    context.callMethod('open', [url]);
    await for (final MessageEvent messageEvent in window.onMessage) {
      if (messageEvent.origin == Uri.base.origin) {
        final flutterWebAuthMessage = messageEvent.data['flutter-web-auth-2'];
        if (flutterWebAuthMessage is String) {
          return flutterWebAuthMessage;
        }
      }
      final appleOrigin = Uri(scheme: 'https', host: 'appleid.apple.com');
      if (messageEvent.origin == appleOrigin.toString()) {
        try {
          final data = jsonDecode(messageEvent.data.toString());
          if (data['method'] == 'oauthDone') {
            final appleAuth =
                data['data']['authorization'] as Map<String, dynamic>?;
            if (appleAuth != null) {
              final appleAuthQuery = Uri(queryParameters: appleAuth).query;
              return appleOrigin.replace(fragment: appleAuthQuery).toString();
            }
          }
        } on FormatException {
          // ignore exception
        }
      }
    }
    throw PlatformException(
      code: 'error',
      message: 'Iterable window.onMessage is empty',
    );
  }
}
