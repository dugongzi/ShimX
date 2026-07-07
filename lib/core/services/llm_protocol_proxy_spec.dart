import 'package:shimx/core/services/llm_protocol_converter.dart';

enum LlmResponseStreamKind {
  passthrough,
  chatToResponses,
  messagesToResponses,
}

class LlmProtocolSpec {
  const LlmProtocolSpec({
    required this.protocol,
    required this.uri,
    required this.headers,
    required this.responseStreamKind,
  });

  final LlmProtocol protocol;
  final Uri uri;
  final Map<String, String> headers;
  final LlmResponseStreamKind responseStreamKind;
}

LlmProtocolSpec resolveLlmProtocolSpec({
  required String baseUrl,
  required Uri requestUri,
  required String apiKey,
  required String upstreamProtocol,
}) {
  final base = Uri.tryParse(baseUrl);
  if (base == null || base.host.isEmpty) {
    throw ArgumentError.value(baseUrl, 'baseUrl', 'Invalid upstream base URL');
  }

  final protocol = parseLlmProtocol(upstreamProtocol);
  return LlmProtocolSpec(
    protocol: protocol,
    uri: _resolveUri(base, requestUri, protocol),
    headers: _resolveHeaders(apiKey, protocol),
    responseStreamKind: _resolveStreamKind(protocol),
  );
}

Uri _resolveUri(Uri base, Uri requestUri, LlmProtocol protocol) {
  final path = switch (protocol) {
    LlmProtocol.responses => requestUri.path,
    LlmProtocol.chat => '${_trimTrailingSlash(base.path)}/chat/completions',
    LlmProtocol.messages => '${_trimTrailingSlash(base.path)}/messages',
  };
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: path,
    query: requestUri.query.isEmpty ? null : requestUri.query,
  );
}

Map<String, String> _resolveHeaders(String apiKey, LlmProtocol protocol) {
  final headers = <String, String>{
    'authorization': 'Bearer $apiKey',
  };
  if (protocol == LlmProtocol.messages) {
    headers['x-api-key'] = apiKey;
    headers['anthropic-version'] = '2023-06-01';
  }
  return headers;
}

LlmResponseStreamKind _resolveStreamKind(LlmProtocol protocol) {
  return switch (protocol) {
    LlmProtocol.responses => LlmResponseStreamKind.passthrough,
    LlmProtocol.chat => LlmResponseStreamKind.chatToResponses,
    LlmProtocol.messages => LlmResponseStreamKind.messagesToResponses,
  };
}

String _trimTrailingSlash(String path) {
  return path.replaceAll(RegExp(r'/+$'), '');
}
