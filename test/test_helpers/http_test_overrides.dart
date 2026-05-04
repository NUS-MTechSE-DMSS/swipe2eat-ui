import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

typedef TestHttpMatcher = bool Function(CapturedHttpRequest request);
typedef TestHttpHandler =
    FutureOr<StubHttpResponse> Function(CapturedHttpRequest request);

class CapturedHttpRequest {
  CapturedHttpRequest({
    required this.method,
    required this.uri,
    required this.headers,
    required this.bodyBytes,
  });

  final String method;
  final Uri uri;
  final Map<String, String> headers;
  final List<int> bodyBytes;

  String get body => utf8.decode(bodyBytes, allowMalformed: true);
}

class StubHttpResponse {
  const StubHttpResponse({
    required this.statusCode,
    this.body = '',
    this.bodyBytes,
    this.headers = const <String, String>{},
    this.reasonPhrase = 'OK',
    this.delay,
  });

  factory StubHttpResponse.json(
    Object? json, {
    int statusCode = 200,
    Map<String, String> headers = const <String, String>{},
    String reasonPhrase = 'OK',
    Duration? delay,
  }) {
    return StubHttpResponse(
      statusCode: statusCode,
      body: jsonEncode(json),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json',
        ...headers,
      },
      reasonPhrase: reasonPhrase,
      delay: delay,
    );
  }

  final int statusCode;
  final String body;
  final List<int>? bodyBytes;
  final Map<String, String> headers;
  final String reasonPhrase;
  final Duration? delay;

  List<int> get resolvedBodyBytes => bodyBytes ?? utf8.encode(body);
}

class HttpTestOverrides extends HttpOverrides {
  final List<_StubbedRoute> _routes = <_StubbedRoute>[];
  final List<CapturedHttpRequest> requests = <CapturedHttpRequest>[];

  void addResponse({
    required String method,
    required String url,
    required StubHttpResponse response,
  }) {
    addHandler(
      matcher: (request) =>
          request.method == method.toUpperCase() &&
          request.uri.toString() == url,
      handler: (_) => response,
    );
  }

  void addHandler({
    required TestHttpMatcher matcher,
    required TestHttpHandler handler,
  }) {
    _routes.add(_StubbedRoute(matcher: matcher, handler: handler));
  }

  CapturedHttpRequest? lastRequestMatching(TestHttpMatcher matcher) {
    for (final request in requests.reversed) {
      if (matcher(request)) {
        return request;
      }
    }
    return null;
  }

  void clear() {
    _routes.clear();
    requests.clear();
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient(this);
  }

  Future<StubHttpResponse> resolve(CapturedHttpRequest request) async {
    requests.add(request);

    for (final route in _routes) {
      if (route.matcher(request)) {
        final response = await route.handler(request);
        if (response.delay != null) {
          await Future<void>.delayed(response.delay!);
        }
        return response;
      }
    }

    throw StateError('No HTTP stub matched ${request.method} ${request.uri}');
  }
}

class _StubbedRoute {
  const _StubbedRoute({required this.matcher, required this.handler});

  final TestHttpMatcher matcher;
  final TestHttpHandler handler;
}

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this._overrides);

  final HttpTestOverrides _overrides;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _FakeHttpClientRequest(_overrides, method.toUpperCase(), url);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) => openUrl('GET', url);

  @override
  Future<HttpClientRequest> postUrl(Uri url) => openUrl('POST', url);

  @override
  Future<HttpClientRequest> putUrl(Uri url) => openUrl('PUT', url);

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) => openUrl('DELETE', url);

  @override
  void close({bool force = false}) {}

  @override
  bool get autoUncompress => true;

  @override
  set autoUncompress(bool value) {}

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  Future<bool> Function(Uri, String, String?)? authenticate;

  @override
  Future<bool> Function(String, int, String, String?)? authenticateProxy;

  @override
  bool Function(X509Certificate cert, String host, int port)?
  badCertificateCallback;

  @override
  String Function(Uri url)? findProxy;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientRequest implements HttpClientRequest {
  _FakeHttpClientRequest(this._overrides, this._method, this._uri);

  final HttpTestOverrides _overrides;
  final String _method;
  final Uri _uri;
  final BytesBuilder _body = BytesBuilder(copy: false);
  final _FakeHttpHeaders _headers = _FakeHttpHeaders();
  final Completer<HttpClientResponse> _done = Completer<HttpClientResponse>();

  bool _closed = false;

  @override
  _FakeHttpHeaders get headers => _headers;

  @override
  Encoding encoding = utf8;

  @override
  bool bufferOutput = false;

  @override
  int contentLength = -1;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  Future<HttpClientResponse> get done => _done.future;

  @override
  void add(List<int> data) {
    _body.add(data);
  }

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final chunk in stream) {
      add(chunk);
    }
  }

  @override
  void write(Object? object) {
    add(encoding.encode(object?.toString() ?? ''));
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {
    write(objects.join(separator));
  }

  @override
  void writeln([Object? object = '']) {
    write('${object ?? ''}\n');
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  Future<HttpClientResponse> close() async {
    if (_closed) {
      return _done.future;
    }
    _closed = true;

    final request = CapturedHttpRequest(
      method: _method,
      uri: _uri,
      headers: _headers.asSimpleMap(),
      bodyBytes: _body.takeBytes(),
    );
    final stub = await _overrides.resolve(request);
    final response = _FakeHttpClientResponse(stub);
    _done.complete(response);
    return response;
  }

  @override
  Future<void> flush() async {}

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {
    if (_done.isCompleted) {
      return;
    }
    _done.completeError(
      exception ?? const HttpException('Request aborted'),
      stackTrace,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _values = <String, List<String>>{};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    final key = name.toLowerCase();
    _values.putIfAbsent(key, () => <String>[]).add(value.toString());
  }

  Map<String, String> asSimpleMap() {
    return <String, String>{
      for (final entry in _values.entries) entry.key: entry.value.join(','),
    };
  }

  @override
  List<String>? operator [](String name) => _values[name.toLowerCase()];

  @override
  void clear() {
    _values.clear();
  }

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _values.forEach(action);
  }

  @override
  void noFolding(String name) {}

  @override
  void remove(String name, Object value) {
    final key = name.toLowerCase();
    final existing = _values[key];
    if (existing == null) {
      return;
    }
    existing.remove(value.toString());
    if (existing.isEmpty) {
      _values.remove(key);
    }
  }

  @override
  void removeAll(String name) {
    _values.remove(name.toLowerCase());
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = <String>[value.toString()];
  }

  @override
  String? value(String name) {
    final values = this[name];
    if (values == null || values.isEmpty) {
      return null;
    }
    if (values.length > 1) {
      throw HttpException('More than one value for header $name');
    }
    return values.single;
  }

  @override
  ContentType? get contentType {
    final raw = value(HttpHeaders.contentTypeHeader);
    return raw == null ? null : ContentType.parse(raw);
  }

  @override
  set contentType(ContentType? value) {
    if (value == null) {
      removeAll(HttpHeaders.contentTypeHeader);
    } else {
      set(HttpHeaders.contentTypeHeader, value.toString());
    }
  }

  @override
  DateTime? date;

  @override
  DateTime? expires;

  @override
  String? host;

  @override
  int? port;

  @override
  int contentLength = -1;

  @override
  bool chunkedTransferEncoding = false;

  @override
  bool persistentConnection = true;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse(this._stub) : headers = _FakeHttpHeaders() {
    for (final entry in _stub.headers.entries) {
      headers.set(entry.key, entry.value);
    }
  }

  final StubHttpResponse _stub;

  @override
  final _FakeHttpHeaders headers;

  @override
  int get statusCode => _stub.statusCode;

  @override
  int get contentLength => _stub.resolvedBodyBytes.length;

  @override
  bool get isRedirect =>
      statusCode >= 300 &&
      statusCode < 400 &&
      headers.value(HttpHeaders.locationHeader) != null;

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => _stub.reasonPhrase;

  @override
  List<RedirectInfo> get redirects => const <RedirectInfo>[];

  @override
  X509Certificate? get certificate => null;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> get cookies => const <Cookie>[];

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  Future<Socket> detachSocket() {
    throw UnimplementedError('detachSocket is not supported in tests');
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final body = _stub.resolvedBodyBytes;
    final stream = body.isEmpty
        ? Stream<List<int>>.empty()
        : Stream<List<int>>.value(body);
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
