import 'package:flutter_web_auth_platform_interface/method_channel_flutter_web_auth.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of FlutterWebAuth must implement.
///
/// Platform implementations should extend this class rather than implement it
/// because `implements` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation.
abstract class FlutterWebAuthPlatformInterface extends PlatformInterface {
  FlutterWebAuthPlatformInterface() : super(token: _token);

  static FlutterWebAuthPlatformInterface _instance = MethodChannelFlutterWebAuth();

  static final Object _token = Object();

  static FlutterWebAuthPlatformInterface get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UrlLauncherPlatform] when they register themselves.
  static set instance(FlutterWebAuthPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> authenticate({required String url, required String callbackUrlScheme, required bool preferEphemeral}) {
    throw UnimplementedError('authenticate() has not been implemented.');
  }

  Future clearAllDanglingCalls() {
    throw UnimplementedError('clearAllDanglingCalls() has not been implemented.');
  }
}
