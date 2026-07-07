import 'package:flutter_test/flutter_test.dart';
import 'package:shimx/core/services/llm_protocol_converter.dart';
import 'package:shimx/core/services/llm_protocol_proxy_spec.dart';

void main() {
  group('resolveLlmProtocolSpec', () {
    test('responses keeps request path and passthrough stream', () {
      final spec = resolveLlmProtocolSpec(
        baseUrl: 'https://api.example.com/v1',
        requestUri: Uri.parse('/v1/responses?foo=bar'),
        apiKey: 'sk-test',
        upstreamProtocol: 'responses',
      );

      expect(spec.protocol, LlmProtocol.responses);
      expect(spec.uri.toString(), 'https://api.example.com/v1/responses?foo=bar');
      expect(spec.headers, {'authorization': 'Bearer sk-test'});
      expect(spec.responseStreamKind, LlmResponseStreamKind.passthrough);
    });

    test('chat uses chat completions route and chat stream transformer', () {
      final spec = resolveLlmProtocolSpec(
        baseUrl: 'https://api.example.com/v1/',
        requestUri: Uri.parse('/v1/responses'),
        apiKey: 'sk-test',
        upstreamProtocol: 'chat',
      );

      expect(spec.protocol, LlmProtocol.chat);
      expect(spec.uri.toString(), 'https://api.example.com/v1/chat/completions');
      expect(spec.headers, {'authorization': 'Bearer sk-test'});
      expect(spec.responseStreamKind, LlmResponseStreamKind.chatToResponses);
    });

    test('messages uses messages route anthropic headers and messages stream transformer', () {
      final spec = resolveLlmProtocolSpec(
        baseUrl: 'https://api.example.com/v1/',
        requestUri: Uri.parse('/v1/responses'),
        apiKey: 'sk-test',
        upstreamProtocol: 'messages',
      );

      expect(spec.protocol, LlmProtocol.messages);
      expect(spec.uri.toString(), 'https://api.example.com/v1/messages');
      expect(spec.headers, {
        'authorization': 'Bearer sk-test',
        'x-api-key': 'sk-test',
        'anthropic-version': '2023-06-01',
      });
      expect(spec.responseStreamKind, LlmResponseStreamKind.messagesToResponses);
    });
  });
}
