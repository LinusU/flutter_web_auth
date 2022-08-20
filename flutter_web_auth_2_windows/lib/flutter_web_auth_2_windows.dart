import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:win32/win32.dart';

/// HTML code that generates a nice callback page.
const html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Access Granted</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; padding: 0; }

    main {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif,Apple Color Emoji,Segoe UI Emoji,Segoe UI Symbol;
    }

    #text {
      padding: 2em;
      text-align: center;
      font-size: 2rem;
    }
  </style>
</head>
<body>
  <main>
    <div id="text">You may now close this page</div>
  </main>
</body>
</html>
''';

/// Implements the plugin interface for Windows.
class FlutterWebAuth2Windows extends FlutterWebAuth2PlatformInterface {
  HttpServer? _server;
  Timer? _authTimeout;

  /// Registers the Windows implementation.
  static void registerWith() {
    FlutterWebAuth2PlatformInterface.instance = FlutterWebAuth2Windows();
  }

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required bool preferEphemeral,
  }) async {
    // Validate callback url
    final callbackUri = Uri.parse(callbackUrlScheme);

    if (callbackUri.scheme != 'http' ||
        callbackUri.host != 'localhost' ||
        !callbackUri.hasPort) {
      throw ArgumentError(
        'Callback url scheme must start with http://localhost:{port}',
      );
    }

    await _server?.close(force: true);

    _server = await HttpServer.bind('127.0.0.1', callbackUri.port);
    String? result;

    _authTimeout?.cancel();
    _authTimeout = Timer(const Duration(seconds: 90), () {
      _server?.close();
    });

    await launchUrl(Uri.parse(url));

    await _server!.listen((req) async {
      req.response.headers.add('Content-Type', 'text/html');
      req.response.write(html);
      await req.response.close();

      result = req.requestedUri.toString();
      await _server?.close();
      _server = null;
    }).asFuture();

    await _server?.close(force: true);
    _authTimeout?.cancel();

    if (result != null) {
      _bringWindowToFront();
      return result!;
    }
    throw PlatformException(message: 'User canceled login', code: 'CANCELED');
  }

  @override
  Future clearAllDanglingCalls() async {
    await _server?.close(force: true);
  }

  void _bringWindowToFront() {
    // https://stackoverflow.com/questions/916259/win32-bring-a-window-to-top/34414846#34414846

    final lWindowName = 'FLUTTER_RUNNER_WIN32_WINDOW'.toNativeUtf16();
    final mHWnd = FindWindow(lWindowName, nullptr);
    free(lWindowName);

    final hCurWnd = GetForegroundWindow();
    final dwMyID = GetCurrentThreadId();
    final dwCurID = GetWindowThreadProcessId(hCurWnd, nullptr);
    AttachThreadInput(dwCurID, dwMyID, TRUE);
    SetWindowPos(mHWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
    SetWindowPos(
      mHWnd,
      HWND_NOTOPMOST,
      0,
      0,
      0,
      0,
      SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE,
    );
    SetForegroundWindow(mHWnd);
    SetFocus(mHWnd);
    SetActiveWindow(mHWnd);
    AttachThreadInput(dwCurID, dwMyID, FALSE);
  }
}
