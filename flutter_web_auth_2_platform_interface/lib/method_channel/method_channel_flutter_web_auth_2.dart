import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';

/// Method channel implementation of the [FlutterWebAuth2Platform].
class FlutterWebAuth2MethodChannel extends FlutterWebAuth2Platform {
  static const MethodChannel channel = MethodChannel('flutter_web_auth_2');

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required bool preferEphemeral,
    String? redirectOriginOverride,
    List contextArgs = const [],
  }) async =>
      await channel.invokeMethod<String>('authenticate', <String, dynamic>{
        'url': url,
        'callbackUrlScheme': callbackUrlScheme,
        'preferEphemeral': preferEphemeral,
        'redirectOriginOverride': redirectOriginOverride,
        'contextArgs': contextArgs,
      }) ??
      '';

  @override
  Future clearAllDanglingCalls() async =>
      channel.invokeMethod('cleanUpDanglingCalls');
}
