import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_web_auth_platform_interface/flutter_web_auth_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';

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

    final server = await HttpServer.bind('127.0.0.1', callbackUri.port);
    String? _result;

    launch(url);

    await server.listen((req) async {
      req.response.headers.add('Content-Type', 'text/html');
      req.response.write(html);
      req.response.close();

      _result = req.requestedUri.toString();
      server.close();
    }).asFuture();

    server.close();

    if (_result != null) {
      return _result!;
    }
    throw PlatformException(message: 'User canceled login', code: 'CANCELED');
  }

  @override
  Future clearAllDanglingCalls() async {}
}
