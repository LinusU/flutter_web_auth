import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';

const MethodChannel _kChannel = MethodChannel('flutter_web_auth');

/// Method channel implementation of the [FlutterWebAuth2PlatformInterface].
class FlutterWebAuth2MethodChannel extends FlutterWebAuth2PlatformInterface {
  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required bool preferEphemeral,
  }) async =>
      (await _kChannel.invokeMethod<String>('authenticate', <String, dynamic>{
        'url': url,
        'callbackUrlScheme': callbackUrlScheme,
        'preferEphemeral': preferEphemeral,
      }))!;

  @override
  Future clearAllDanglingCalls() async {
    await _kChannel.invokeMethod('cleanUpDanglingCalls');
  }
}
