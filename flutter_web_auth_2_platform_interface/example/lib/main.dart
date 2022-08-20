import 'dart:async';
import 'dart:io' show HttpServer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

const html = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Grant Access to Flutter</title>
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

    #icon {
      font-size: 96pt;
    }

    #text {
      padding: 2em;
      max-width: 260px;
      text-align: center;
    }

    #button a {
      display: inline-block;
      padding: 6px 12px;
      color: white;
      border: 1px solid rgba(27,31,35,.2);
      border-radius: 3px;
      background-image: linear-gradient(-180deg, #34d058 0%, #22863a 90%);
      text-decoration: none;
      font-size: 14px;
      font-weight: 600;
    }

    #button a:active {
      background-color: #279f43;
      background-image: none;
    }
  </style>
</head>
<body>
  <main>
    <div id="icon">&#x1F3C7;</div>
    <div id="text">Press the button below to sign in using your localhost account.</div>
    <div id="button"><a href="foobar://success?code=1337">Sign in</a></div>
  </main>
</body>
</html>
''';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String _status = '';

  @override
  void initState() {
    super.initState();
    startServer();
  }

  Future<void> startServer() async {
    final server = await HttpServer.bind('127.0.0.1', 43823);

    server.listen((req) async {
      setState(() {
        _status = 'Received request!';
      });

      req.response.headers.add('Content-Type', 'text/html');
      req.response.write(html);
      await req.response.close();
    });
  }

  Future<void> authenticate() async {
    const url = 'http://127.0.0.1:43823/';
    const callbackUrlScheme = 'foobar';

    try {
      final result = await FlutterWebAuth2.authenticate(
        url: url,
        callbackUrlScheme: callbackUrlScheme,
        // If needed: preferEphemeral: true,
      );
      setState(() {
        _status = 'Got result: $result';
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Got error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Web Auth 2 example'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Status: $_status\n'),
                const SizedBox(height: 80),
                ElevatedButton(
                  onPressed: authenticate,
                  child: const Text('Authenticate'),
                ),
              ],
            ),
          ),
        ),
      );
}
