import 'dart:async';

import 'package:flutter/services.dart' show MethodChannel;

class FlutterWebAuth {
  static const MethodChannel _channel = const MethodChannel('flutter_web_auth');


  /// Ask the user to authenticate to the specified web service.
  ///
  /// The page pointed to by [url] will be loaded and displayed to the user. From the page, the user can authenticate herself and grant access to the app. On completion, the service will send a callback URL with an authentication token, and this URL will be result of the returned [Future].
  ///
  /// [callbackUrlScheme] should be a string specifying the scheme of the url that the page will redirect to upon successful authentication.
  /// [preferEphemeral] if this is specified as `true`, an ephemeral web browser session will be used where possible (`FLAG_ACTIVITY_NO_HISTORY` on Android, `prefersEphemeralWebBrowserSession` on iOS/macOS)
  static Future<String> authenticate({required String url, required String callbackUrlScheme, bool? preferEphemeral}) async {
    return await _channel.invokeMethod('authenticate', <String, dynamic>{
      'url': url,
      'callbackUrlScheme': callbackUrlScheme,
      'preferEphemeral': preferEphemeral ?? false,
    }) as String;
  }
}
