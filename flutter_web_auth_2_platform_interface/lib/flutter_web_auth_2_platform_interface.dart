import 'package:flutter_web_auth_2_platform_interface/method_channel/method_channel_flutter_web_auth_2.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of FlutterWebAuth must implement.
///
/// Platform implementations should extend this class rather than implement it
/// because `implements` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation.
abstract class FlutterWebAuth2Platform extends PlatformInterface {
  FlutterWebAuth2Platform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWebAuth2Platform _instance = FlutterWebAuth2MethodChannel();

  static FlutterWebAuth2Platform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [PlatformInterface] when they register themselves.
  static set instance(FlutterWebAuth2Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required bool preferEphemeral,
    String? redirectOriginOverride,
  }) =>
      _instance.authenticate(
        url: url,
        callbackUrlScheme: callbackUrlScheme,
        preferEphemeral: preferEphemeral,
        redirectOriginOverride: redirectOriginOverride,
      );

  Future clearAllDanglingCalls() => _instance.clearAllDanglingCalls();
}
