import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_web_auth');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      expect(methodCall.method, 'authenticate');

      expect(methodCall.arguments['url'] as String, 'https://example.com/login');
      expect(methodCall.arguments['callbackUrlScheme'] as String, 'foobar');

      return 'https://example.com/success';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('authenticate', () async {
    expect(
      await FlutterWebAuth.authenticate(url: 'https://example.com/login', callbackUrlScheme: 'foobar'),
      'https://example.com/success',
    );
  });
}
