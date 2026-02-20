import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Test helper to stub network image requests in widget tests.
///
/// Usage in tests:
/// ```dart
/// import '../../test_helpers/network_image_stub.dart';
///
/// setUpAll(() {
///   HttpOverrides.global = TestHttpOverrides();
/// });
///
/// tearDownAll(() {
///   HttpOverrides.global = null;
/// });
/// ```

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return FakeHttpClient();
  }
}

class FakeHttpClient implements HttpClient {
  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {}

  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {}

  // Match SDK signature: Future<bool> Function(Uri url, String scheme, String? realm)?
  @override
  Future<bool> Function(Uri, String, String?)? authenticate;

  @override
  Future<bool> Function(String, int, String, String?)? authenticateProxy;

  @override
  set autoUncompress(bool value) {}

  @override
  bool get autoUncompress => true;

  @override
  void close({bool force = false}) {}

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => FakeHttpClientRequest();

  // Provide a minimal noSuchMethod fallback for other members not used in tests.
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientRequest implements HttpClientRequest {
  final _controller = StreamController<List<int>>();

  @override
  Future<HttpClientResponse> close() async {
    // 1x1 transparent PNG
    final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII=');
    // push bytes then close stream
    _controller.add(png);
    await _controller.close();
    return FakeHttpClientResponse(Stream.fromIterable([png]));
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpClientResponse extends Stream<List<int>> implements HttpClientResponse {
  final Stream<List<int>> _stream;
  FakeHttpClientResponse(this._stream);

  @override
  int get statusCode => 200;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int>)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _stream.listen(onData as void Function(List<int>)?, onError: onError as void Function(Object, StackTrace)?, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
