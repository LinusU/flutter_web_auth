import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show MethodChannel;

class _OnAppLifecycleResumeObserver extends WidgetsBindingObserver {
  final Function onResumed;

  _OnAppLifecycleResumeObserver(this.onResumed);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}

class FlutterWebAuth {
  static const MethodChannel _channel = const MethodChannel('flutter_web_auth');

  static final _OnAppLifecycleResumeObserver _resumedObserver = _OnAppLifecycleResumeObserver(() {
    _cleanUpDanglingCalls(); // unawaited
  });

  /// Ask the user to authenticate to the specified web service.
  ///
  /// The page pointed to by [url] will be loaded and displayed to the user. From the page, the user can authenticate herself and grant access to the app. On completion, the service will send a callback URL with an authentication token, and this URL will be result of the returned [Future].
  ///
  /// [callbackUrlScheme] should be a string specifying the scheme of the url that the page will redirect to upon successful authentication.
  static Future<String> authenticate({required String url, required String callbackUrlScheme}) async {
    _SchemeValidator.validate(callbackUrlScheme);
    WidgetsBinding.instance?.removeObserver(_resumedObserver); // safety measure so we never add this observer twice
    WidgetsBinding.instance?.addObserver(_resumedObserver);
    return await _channel.invokeMethod('authenticate', <String, dynamic>{
      'url': url,
      'callbackUrlScheme': callbackUrlScheme,
    }) as String;
  }

  /// On Android, the plugin has to store the Result callbacks in order to pass the result back to the caller of
  /// `authenticate`. But if that result never comes the callback will dangle around forever. This can be called to
  /// terminate all `authenticate` calls with an error.
  static Future<void> _cleanUpDanglingCalls() async {
    await _channel.invokeMethod('cleanUpDanglingCalls');
    WidgetsBinding.instance?.removeObserver(_resumedObserver);
  }
}

/// part of dart:core uri.dart
class _SchemeValidator {
  static const int _LOWER_CASE_A = 0x61;
  static const int _LOWER_CASE_Z = 0x7A;

  // Characters allowed in the scheme.
  static const _schemeTable = <int>[
    //                     LSB            MSB
    //                      |              |
    0x0000, // 0x00 - 0x0f  0000000000000000
    0x0000, // 0x10 - 0x1f  0000000000000000
    //                                 + -.
    0x6800, // 0x20 - 0x2f  0000000000010110
    //                      0123456789
    0x03ff, // 0x30 - 0x3f  1111111111000000
    //                       ABCDEFGHIJKLMNO
    0xfffe, // 0x40 - 0x4f  0111111111111111
    //                      PQRSTUVWXYZ
    0x07ff, // 0x50 - 0x5f  1111111111100001
    //                       abcdefghijklmno
    0xfffe, // 0x60 - 0x6f  0111111111111111
    //                      pqrstuvwxyz
    0x07ff, // 0x70 - 0x7f  1111111111100010
  ];

  static bool _isAlphabeticCharacter(int codeUnit) {
    var lowerCase = codeUnit | 0x20;
    return (_LOWER_CASE_A <= lowerCase && lowerCase <= _LOWER_CASE_Z);
  }

  static bool _isSchemeCharacter(int ch) {
    return ch < 128 && ((_schemeTable[ch >> 4] & (1 << (ch & 0x0f))) != 0);
  }

  /// Validates scheme characters.
  ///
  /// Schemes cannot contain escapes.
  static void validate(String scheme) {
    if (scheme.isEmpty) {
      _fail(scheme, null, "Scheme cannot be empty");
    }
    final int firstCodeUnit = scheme.codeUnitAt(0);
    if (!_isAlphabeticCharacter(firstCodeUnit)) {
      _fail(scheme, 0, "Scheme not starting with alphabetic character");
    }
    for (int i = 0; i < scheme.length; i++) {
      final int codeUnit = scheme.codeUnitAt(i);
      if (!_isSchemeCharacter(codeUnit)) {
        _fail(scheme, i, "Illegal scheme character");
      }
    }
  }

  static Never _fail(String uri, int? index, String message) {
    throw FormatException(message, uri, index);
  }
}
