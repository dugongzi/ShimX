import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mcp_dart/mcp_dart.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/features/claude_session/domain/repositories/claude_session_query_repository.dart';

final mcpServerRunningPortProvider = Provider<ValueNotifier<int?>>((ref) {
  final notifier = ValueNotifier<int?>(null);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final mcpServiceProvider = Provider<McpService>((ref) {
  final service = McpService();
  final runningPort = ref.read(mcpServerRunningPortProvider);
  ref.onDispose(() {
    unawaited(service.stop());
    runningPort.value = null;
  });
  return service;
});

/// 本地 MCP HTTP server。
///
/// 工具通过 [registerTool] 挂载;本类管 server 生命周期 + HTTP 监听 +
/// DNS rebinding 防护 + 端口绑定。
///
/// 与 [LocalProxyService] 同级。
/// Claude 会话相关工具的注册见同文件下方 [registerClaudeSessionTools]。
class McpService {
  McpService();

  HttpServer? _httpServer;
  McpServer? _mcpServer;
  StreamableHTTPServerTransport? _transport;
  int? _port;
  final Set<String> _registeredToolNames = {};

  /// 待注册工具表(start 之前调用 [registerTool] 会暂存,start 时一并注入)。
  /// 按 name 去重,避免热重载或重启时重复注册同名工具。
  final Map<String, _PendingTool> _pendingTools = {};

  bool get isRunning => _httpServer != null;
  int? get port => _port;

  /// 在 server 启动前后均可调用。如果 server 已在跑,新工具立刻挂到 McpServer 上。
  void registerTool({
    required String name,
    required String description,
    required JsonObject inputSchema,
    required Future<CallToolResult> Function(
      Map<String, dynamic> args,
      RequestHandlerExtra extra,
    )
    callback,
  }) {
    final pending = _PendingTool(
      name: name,
      description: description,
      inputSchema: inputSchema,
      callback: callback,
    );
    _pendingTools[name] = pending;
    final live = _mcpServer;
    if (live != null) {
      if (_registeredToolNames.contains(name)) return;
      _attachTool(live, pending);
      _registeredToolNames.add(name);
    }
  }

  void _attachTool(McpServer server, _PendingTool t) {
    server.registerTool(
      t.name,
      description: t.description,
      inputSchema: t.inputSchema,
      callback: t.callback,
    );
  }

  Future<void> start({required int port}) async {
    if (_httpServer != null && _port == port) return;
    await stop();

    final mcpServer = McpServer(
      Implementation(name: 'shimx', version: '1.0.0'),
      options: McpServerOptions(
        capabilities: ServerCapabilities(tools: ServerCapabilitiesTools()),
      ),
    );
    _registeredToolNames.clear();
    for (final t in _pendingTools.values) {
      _attachTool(mcpServer, t);
      _registeredToolNames.add(t.name);
    }

    final transport = StreamableHTTPServerTransport(
      options: StreamableHTTPServerTransportOptions(
        sessionIdGenerator: () => generateUUID(),
        eventStore: InMemoryEventStore(),
        enableDnsRebindingProtection: true,
        allowedHosts: {'127.0.0.1', 'localhost', '127.0.0.1:$port'},
        allowedOrigins: {'http://127.0.0.1:$port', 'http://localhost:$port'},
      ),
    );

    // mcpServer.connect(transport) 内部会 await transport.start(),
    // 不要在这里再手动调一次,否则会抛 'Transport already started'。
    await mcpServer.connect(transport);

    final httpServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      port,
    );

    _httpServer = httpServer;
    _mcpServer = mcpServer;
    _transport = transport;
    _port = httpServer.port;

    AppLogService.instance.info(
      'McpServer',
      '监听启动 127.0.0.1:${httpServer.port}/mcp',
      details: 'tools=${_pendingTools.length}',
    );

    unawaited(_serveLoop(httpServer, transport));
  }

  Future<void> _serveLoop(
    HttpServer server,
    StreamableHTTPServerTransport transport,
  ) async {
    try {
      await for (final request in server) {
        if (request.uri.path != '/mcp') {
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('Not Found');
          await request.response.close();
          continue;
        }
        try {
          await transport.handleRequest(request);
        } catch (e, st) {
          AppLogService.instance.error(
            'McpServer',
            'handleRequest 异常',
            details: '$e\n$st',
          );
        }
      }
    } catch (e) {
      // server.close 时 StreamSubscription 会抛 'StateError: Bad state: ...',这是正常关闭
      AppLogService.instance.info('McpServer', '监听循环结束', details: '$e');
    }
  }

  Future<void> stop() async {
    final http = _httpServer;
    final mcp = _mcpServer;
    final transport = _transport;
    _httpServer = null;
    _mcpServer = null;
    _transport = null;
    _port = null;
    _registeredToolNames.clear();

    try {
      await transport?.close();
    } catch (_) {}
    try {
      await mcp?.close();
    } catch (_) {}
    if (http != null) {
      await http.close(force: true);
      AppLogService.instance.info('McpServer', '监听已停止');
    }
  }
}

class _PendingTool {
  _PendingTool({
    required this.name,
    required this.description,
    required this.inputSchema,
    required this.callback,
  });
  final String name;
  final String description;
  final JsonObject inputSchema;
  final Future<CallToolResult> Function(
    Map<String, dynamic> args,
    RequestHandlerExtra extra,
  )
  callback;
}

/// 把 Claude 会话查询能力以 MCP 工具形式挂到 [server]。
///
/// 暴露 3 个工具:
///   list_claude_sessions(project_path?)   不传 → 列项目;传 → 列项目下会话
///   read_claude_session(jsonl_path, offset?=0, limit?=50)  分页读消息流
///   search_claude_session(query, project_path?, limit?=20, deep?=false)
void registerClaudeSessionTools(
  McpService server, {
  required ClaudeSessionQueryRepository queryRepository,
}) {
  server.registerTool(
    name: 'list_claude_sessions',
    description:
        'List Claude Code session projects, or sessions inside a project. '
        'Pass no arguments to get a list of projects; pass project_path '
        '(the encodedDir of a project) to get all sessions under it.',
    inputSchema: const JsonObject(
      properties: {
        'project_path': JsonString(
          description:
              'Optional. The encodedDir of a project (returned in the project list). '
              'When omitted, returns all projects.',
        ),
      },
    ),
    callback: (args, extra) async {
      final projectPath = args['project_path'] as String?;
      if (projectPath == null || projectPath.isEmpty) {
        final projects = await queryRepository.listProjects();
        return CallToolResult(
          content: [
            TextContent(
              text: jsonEncode({
                'projects': projects
                    .map(
                      (p) => {
                        'encodedDir': p.encodedDir,
                        'cwd': p.cwd,
                        'sessionCount': p.sessionCount,
                        'lastActiveMs': p.lastActiveMs,
                      },
                    )
                    .toList(),
              }),
            ),
          ],
        );
      }
      final threads = await queryRepository.listThreads(
        encodedDir: projectPath,
      );
      return CallToolResult(
        content: [
          TextContent(
            text: jsonEncode({
              'sessions': threads
                  .map(
                    (t) => {
                      'sessionId': t.sessionId,
                      'jsonlPath': t.jsonlPath,
                      'title': t.title,
                      'cwd': t.cwd,
                      'gitBranch': t.gitBranch,
                      'updatedAtMs': t.updatedAtMs,
                    },
                  )
                  .toList(),
            }),
          ),
        ],
      );
    },
  );

  server.registerTool(
    name: 'read_claude_session',
    description:
        'Read parsed messages of a Claude Code session. Returns a slice '
        '[offset, offset+limit) of the message stream. Use list_claude_sessions '
        'first to get the jsonl_path.',
    inputSchema: const JsonObject(
      properties: {
        'jsonl_path': JsonString(
          description:
              'Full path to the jsonl file (from list_claude_sessions).',
        ),
        'offset': JsonInteger(
          description: 'Start index in the parsed message list. Default 0.',
        ),
        'limit': JsonInteger(
          description: 'Max number of messages to return. Default 50, max 200.',
        ),
      },
      required: ['jsonl_path'],
    ),
    callback: (args, extra) async {
      final path = (args['jsonl_path'] as String?) ?? '';
      final offset = (args['offset'] as int?) ?? 0;
      final rawLimit = (args['limit'] as int?) ?? 50;
      final limit = rawLimit.clamp(1, 200);
      if (path.isEmpty) {
        return CallToolResult(
          isError: true,
          content: const [TextContent(text: 'jsonl_path is required')],
        );
      }
      final detail = await queryRepository.loadThreadDetail(jsonlPath: path);
      final total = detail.messages.length;
      final end = (offset + limit).clamp(0, total);
      final slice = offset >= total
          ? const []
          : detail.messages.sublist(offset, end);
      return CallToolResult(
        content: [
          TextContent(
            text: jsonEncode({
              'sessionId': detail.sessionId,
              'title': detail.title,
              'cwd': detail.cwd,
              'gitBranch': detail.gitBranch,
              'cliVersion': detail.cliVersion,
              'totalMessages': total,
              'offset': offset,
              'limit': limit,
              'hasMore': end < total,
              'messages': slice
                  .map(
                    (m) => {
                      'index': m.index,
                      'timestamp': m.timestamp,
                      'role': m.role,
                      'kind': m.kind,
                      'toolName': m.toolName,
                      'text': m.text,
                    },
                  )
                  .toList(),
            }),
          ),
        ],
      );
    },
  );

  server.registerTool(
    name: 'search_claude_session',
    description:
        'Search Claude Code sessions by keyword. Matches session title and '
        'cwd by default; if deep=true, also scans message contents (slower).',
    inputSchema: const JsonObject(
      properties: {
        'query': JsonString(
          description: 'Substring to look for (case-insensitive).',
        ),
        'project_path': JsonString(
          description: 'Optional encodedDir to scope search to one project.',
        ),
        'limit': JsonInteger(
          description: 'Max hits to return. Default 20, max 100.',
        ),
        'deep': JsonBoolean(
          description:
              'When true, also load each session and scan message text. '
              'Off by default to keep responses fast.',
        ),
      },
      required: ['query'],
    ),
    callback: (args, extra) async {
      final query = ((args['query'] as String?) ?? '').toLowerCase();
      final scopedProject = args['project_path'] as String?;
      final rawLimit = (args['limit'] as int?) ?? 20;
      final limit = rawLimit.clamp(1, 100);
      final deep = (args['deep'] as bool?) ?? false;
      if (query.isEmpty) {
        return CallToolResult(
          isError: true,
          content: const [TextContent(text: 'query is required')],
        );
      }

      final projects = scopedProject == null || scopedProject.isEmpty
          ? await queryRepository.listProjects()
          : (await queryRepository.listProjects())
                .where((p) => p.encodedDir == scopedProject)
                .toList();

      final hits = <Map<String, dynamic>>[];
      outer:
      for (final project in projects) {
        final threads = await queryRepository.listThreads(
          encodedDir: project.encodedDir,
        );
        for (final t in threads) {
          final inMeta =
              t.title.toLowerCase().contains(query) ||
              t.cwd.toLowerCase().contains(query);
          String? snippet;
          if (inMeta) {
            snippet = t.title.isEmpty ? t.cwd : t.title;
          } else if (deep) {
            try {
              final detail = await queryRepository.loadThreadDetail(
                jsonlPath: t.jsonlPath,
              );
              for (final m in detail.messages) {
                final low = m.text.toLowerCase();
                final idx = low.indexOf(query);
                if (idx >= 0) {
                  final start = (idx - 40).clamp(0, m.text.length);
                  final end = (idx + query.length + 80).clamp(0, m.text.length);
                  snippet = m.text.substring(start, end);
                  break;
                }
              }
            } catch (_) {}
          }
          if (snippet != null) {
            hits.add({
              'projectEncodedDir': project.encodedDir,
              'projectCwd': project.cwd,
              'sessionId': t.sessionId,
              'jsonlPath': t.jsonlPath,
              'title': t.title,
              'updatedAtMs': t.updatedAtMs,
              'snippet': snippet,
            });
            if (hits.length >= limit) break outer;
          }
        }
      }

      return CallToolResult(
        content: [
          TextContent(text: jsonEncode({'hits': hits})),
        ],
      );
    },
  );
}
