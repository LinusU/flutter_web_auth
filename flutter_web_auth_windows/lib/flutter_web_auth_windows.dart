import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_platform_interface/flutter_web_auth_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:win32/win32.dart';
import 'package:ffi/ffi.dart';

const html = """
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
""";

class FlutterWebAuthWindows extends FlutterWebAuthPlatformInterface {
  HttpServer? _server;

  /// Registers the Windows implementation.
  static void registerWith() {
    FlutterWebAuthPlatformInterface.instance = FlutterWebAuthWindows();
  }

  @override
  Future<String> authenticate(
      {required String url, required String callbackUrlScheme, required bool preferEphemeral}) async {
    // Validate callback url
    final callbackUri = Uri.parse(callbackUrlScheme);

    if (callbackUri.scheme != "http" || callbackUri.host != "localhost" || !callbackUri.hasPort) {
      throw ArgumentError('Callback url scheme must start with http://localhost:{port}');
    }

    await _server?.close(force: true);

    _server = await HttpServer.bind('127.0.0.1', callbackUri.port);
    String? _result;

    launch(url);

    await _server!.listen((req) async {
      req.response.headers.add('Content-Type', 'text/html');
      req.response.write(html);
      req.response.close();

      _result = req.requestedUri.toString();
      _server?.close();
      _server = null;
    }).asFuture();

    _server?.close(force: true);

    if (_result != null) {
      _bringWindowToFront();
      return _result!;
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
    final m_hWnd = FindWindow(lWindowName, nullptr);
    free(lWindowName);

    final hCurWnd = GetForegroundWindow();
    final dwMyID = GetCurrentThreadId();
    final dwCurID = GetWindowThreadProcessId(hCurWnd, nullptr);
    AttachThreadInput(dwCurID, dwMyID, TRUE);
    SetWindowPos(m_hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
    SetWindowPos(m_hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
    SetForegroundWindow(m_hWnd);
    SetFocus(m_hWnd);
    SetActiveWindow(m_hWnd);
    AttachThreadInput(dwCurID, dwMyID, FALSE);
  }
}
