import 'package:flutter/services.dart';
import 'package:flutter_web_auth_platform_interface/flutter_web_auth_platform_interface.dart';

const MethodChannel _kChannel = MethodChannel('flutter_web_auth');

/// Method channel implementation of the [WakelockPlatformInterface].
class MethodChannelFlutterWebAuth extends FlutterWebAuthPlatformInterface {
  @override
  Future<String> authenticate(
      {required String url, required String callbackUrlScheme, bool preferEphemeral = false}) async {
    return await _kChannel.invokeMethod('authenticate', <String, dynamic>{
      'url': url,
      'callbackUrlScheme': callbackUrlScheme,
      'preferEphemeral': preferEphemeral,
    });
  }

  @override
  Future clearAllDanglingCalls() async {
    await _kChannel.invokeMethod('cleanUpDanglingCalls');
  }
}
