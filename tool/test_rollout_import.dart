// 一次性验证脚本 v2:三件全写(rollout + threads 表 + session_index.jsonl)
//
// v1 实验结论:codex 启动并不会自动从 rollout 文件 backfill threads 表。
// 真索引是 `~/.codex/session_index.jsonl` + `state_5.sqlite` 的 threads 表,
// rollout 文件本身只是消息内容载体。
//
// 用法:
//   dart run tool/test_rollout_import.dart
//
// 验证步骤:
//   1. 跑这个脚本,它会输出生成的 thread id
//   2. 完全退出 codex(任务管理器看一下别留后台进程)
//   3. 重启 codex
//   4. 在 shim 项目下看是否出现一条 "Shim 导入测试" 的新 thread
//   5. 点开它,应该能看到 1 条 user + 1 条 assistant 消息
//
// 回滚:删 jsonl 文件 + 删 sqlite 行 + 删 session_index.jsonl 末尾对应行。
// 如果脚本崩了导致 sqlite 损坏,Codex 启动可能失败 ── 重命名 state_5.sqlite{,-wal,-shm}
// 让 codex 重新 migrate 即可恢复(rollout 内容仍在,不会真正丢数据)。

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:sqlite3/sqlite3.dart';

void main() async {
  final home = Platform.isWindows
      ? Platform.environment['USERPROFILE']
      : Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    stderr.writeln('cannot resolve user home');
    exit(1);
  }

  // 1. 生成 UUIDv7
  final threadId = _uuidV7();
  final turnId = _uuidV7();

  // 2. 时间
  final nowUtc = DateTime.now().toUtc();
  final nowLocal = DateTime.now();
  final tsUtc = _iso8601Z(nowUtc); // 顶层 timestamp
  final tsLocalFile =
      _fileNameTimestamp(nowLocal); // 文件名时间戳(本地时区,T 和 - 分隔)

  // 3. 文件路径(本地时间 YYYY/MM/DD)
  final yyyy = nowLocal.year.toString().padLeft(4, '0');
  final mm = nowLocal.month.toString().padLeft(2, '0');
  final dd = nowLocal.day.toString().padLeft(2, '0');
  final dir = Directory('$home/.codex/sessions/$yyyy/$mm/$dd');
  await dir.create(recursive: true);
  final file = File('${dir.path}/rollout-$tsLocalFile-$threadId.jsonl');

  // 4. 准备 cwd —— Windows 上 codex 真实用的是 UNC long-path 格式 `\\?\X:\...`(大写盘符)
  // 这是 codex 在 sqlite 里分组项目的 key,**必须逐字节匹配**,否则会被分到不同项目。
  final cwd = r'\\?\F:\Programming_projects\FlutterProject\shim';

  // 5. 拼 rollout 内容(按调查报告里观察的真实 codex rollout 头部顺序)
  final lines = <String>[];

  // 5.1 session_meta
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'session_meta',
    'payload': {
      'id': threadId,
      'timestamp': tsUtc,
      'cwd': cwd,
      'originator': 'codex_vscode',
      'cli_version': '0.107.0-alpha.5',
      'source': 'vscode',
      'model_provider': 'rayincode',
      'base_instructions': {
        'text': 'You are Codex, a coding agent. (shim import test)',
      },
      'git': {
        'commit_hash': '0000000000000000000000000000000000000000',
        'branch': 'master',
      },
    },
  }));

  // 5.2 developer message (permissions placeholder)
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'response_item',
    'payload': {
      'type': 'message',
      'role': 'developer',
      'content': [
        {
          'type': 'input_text',
          'text':
              '<permissions instructions>\nShim 导入测试占位 permissions 块。\n</permissions instructions>',
        }
      ],
    },
  }));

  // 5.3 user message (AGENTS.md + environment_context placeholder)
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'response_item',
    'payload': {
      'type': 'message',
      'role': 'user',
      'content': [
        {
          'type': 'input_text',
          'text':
              '<environment_context>\n  <cwd>$cwd</cwd>\n  <shell>powershell</shell>\n  <current_date>$yyyy-$mm-$dd</current_date>\n  <timezone>Asia/Shanghai</timezone>\n</environment_context>',
        }
      ],
    },
  }));

  // 5.4 event_msg task_started
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'event_msg',
    'payload': {
      'type': 'task_started',
      'turn_id': turnId,
      'model_context_window': 200000,
      'collaboration_mode_kind': 'default',
    },
  }));

  // 5.5 developer message (collaboration_mode)
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'response_item',
    'payload': {
      'type': 'message',
      'role': 'developer',
      'content': [
        {
          'type': 'input_text',
          'text':
              '<collaboration_mode>\nShim 导入测试占位 collaboration_mode。\n</collaboration_mode>',
        }
      ],
    },
  }));

  // 5.6 真正的用户消息(这条 codex 应该会拿来生成 thread 的 title/preview)
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'response_item',
    'payload': {
      'type': 'message',
      'role': 'user',
      'content': [
        {
          'type': 'input_text',
          'text': 'Shim 导入测试:这是一条由 shim 测试脚本写入的用户消息。',
        }
      ],
    },
  }));

  // 5.7 user_message event(codex UI 用来在自己的事件流里显示)
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'event_msg',
    'payload': {
      'type': 'user_message',
      'message': 'Shim 导入测试:这是一条由 shim 测试脚本写入的用户消息。',
      'images': [],
      'local_images': [],
      'text_elements': [],
    },
  }));

  // 5.8 turn_context
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'turn_context',
    'payload': {
      'turn_id': turnId,
      'cwd': cwd,
      'current_date': '$yyyy-$mm-$dd',
      'timezone': 'Asia/Shanghai',
      'approval_policy': 'on-request',
      'sandbox_policy': {'type': 'read-only'},
      'model': 'gpt-5.3-codex',
      'personality': 'pragmatic',
      'effort': 'xhigh',
      'summary': 'auto',
      'truncation_policy': {'mode': 'tokens', 'limit': 10000},
    },
  }));

  // 5.9 assistant 回复
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'response_item',
    'payload': {
      'type': 'message',
      'role': 'assistant',
      'content': [
        {
          'type': 'output_text',
          'text': '收到。这是一条由 shim 测试脚本写入的 assistant 回复,用于验证 codex 是否能 backfill 出此 thread 并正确渲染消息。',
        }
      ],
      'phase': 'final_answer',
    },
  }));

  // 5.10 agent_message event
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'event_msg',
    'payload': {
      'type': 'agent_message',
      'message': '收到。这是一条由 shim 测试脚本写入的 assistant 回复,用于验证 codex 是否能 backfill 出此 thread 并正确渲染消息。',
    },
  }));

  // 5.11 task_complete
  lines.add(jsonEncode({
    'timestamp': tsUtc,
    'type': 'event_msg',
    'payload': {
      'type': 'task_complete',
      'turn_id': turnId,
      'last_agent_message': '收到。',
    },
  }));

  await file.writeAsString('${lines.join('\n')}\n');

  // === 写 sqlite threads 表 ===
  final dbPath = '$home/.codex/state_5.sqlite';
  final dbFile = File(dbPath);
  if (!dbFile.existsSync()) {
    stderr.writeln('ERROR: state_5.sqlite not found at $dbPath');
    exit(2);
  }
  // 备份(脚本可能崩,先 backup)
  final backupPath = '$dbPath.shim-backup-${nowLocal.millisecondsSinceEpoch}';
  await dbFile.copy(backupPath);

  final db = sqlite3.open(dbPath);
  try {
    final createdAt = nowUtc.millisecondsSinceEpoch ~/ 1000;
    final updatedAt = createdAt;
    final createdAtMs = nowUtc.millisecondsSinceEpoch;
    final updatedAtMs = createdAtMs;
    final firstUserMsg = 'Shim 导入测试';

    // sandbox_policy 抄真实 thread 的简化版(read-only,不要求复杂权限)
    final sandboxPolicy = jsonEncode({
      'type': 'managed',
      'file_system': {'type': 'unrestricted'},
      'network': 'enabled',
    });

    db.execute(
      '''
      INSERT INTO threads (
        id, rollout_path, created_at, updated_at, source, model_provider, cwd,
        title, sandbox_policy, approval_mode, tokens_used, has_user_event,
        archived, cli_version, first_user_message, memory_mode, model,
        reasoning_effort, created_at_ms, updated_at_ms, thread_source, preview,
        recency_at, recency_at_ms
      ) VALUES (
        ?, ?, ?, ?, ?, ?, ?,
        ?, ?, ?, ?, ?,
        ?, ?, ?, ?, ?,
        ?, ?, ?, ?, ?,
        ?, ?
      )
      ''',
      [
        threadId,
        file.path.replaceAll('/', r'\\'), // sqlite 里存 Windows 反斜杠
        createdAt,
        updatedAt,
        'vscode',
        'custom',
        cwd,
        firstUserMsg,
        sandboxPolicy,
        'on-request',
        0,
        1, // has_user_event = 1 (有用户消息)
        0,
        '0.107.0-alpha.5',
        firstUserMsg,
        'enabled',
        'gpt-5.5',
        'high',
        createdAtMs,
        updatedAtMs,
        'user',
        firstUserMsg,
        updatedAt,
        updatedAtMs,
      ],
    );
  } finally {
    db.dispose();
  }

  // === append session_index.jsonl ===
  final idxFile = File('$home/.codex/session_index.jsonl');
  final idxLine = jsonEncode({
    'id': threadId,
    'thread_name': 'Shim 导入测试',
    'updated_at': tsUtc,
  });
  // 用追加模式写
  await idxFile.writeAsString('$idxLine\n', mode: FileMode.append);

  stdout.writeln('========== Shim Rollout Import Test v2 ==========');
  stdout.writeln('rollout:  ${file.path}');
  stdout.writeln('sqlite:   已 INSERT 一行 thread(备份在 $backupPath)');
  stdout.writeln('index:    已追加一行到 ~/.codex/session_index.jsonl');
  stdout.writeln('');
  stdout.writeln('Thread ID: $threadId');
  stdout.writeln('Cwd:       $cwd');
  stdout.writeln('');
  stdout.writeln('下一步:');
  stdout.writeln('  1) 完全退出 codex(任务管理器看下别留后台进程)');
  stdout.writeln('  2) 重启 codex');
  stdout.writeln('  3) 在 shim 项目下找 "Shim 导入测试" thread');
  stdout.writeln('');
  stdout.writeln('回滚:');
  stdout.writeln('  - 删 rollout: rm "${file.path}"');
  stdout.writeln('  - 删 sqlite 行: sqlite3 "$dbPath" "DELETE FROM threads WHERE id=\'$threadId\'"');
  stdout.writeln('  - 索引文件删尾行(或忽略 codex 应能自愈)');
  stdout.writeln('  - 灾难恢复: 拷回备份 $backupPath');
}

/// 生成 UUIDv7(时间戳前缀 48bit + version 7 + 随机)。
/// 格式: xxxxxxxx-xxxx-7xxx-yxxx-xxxxxxxxxxxx (y 是 8/9/a/b)
String _uuidV7() {
  final rng = Random.secure();
  final nowMs = DateTime.now().millisecondsSinceEpoch;
  final bytes = List<int>.filled(16, 0);

  // 前 6 字节 = 48bit 毫秒时间戳(big-endian)
  for (int i = 0; i < 6; i++) {
    bytes[5 - i] = (nowMs >> (i * 8)) & 0xff;
  }
  // 后 10 字节随机
  for (int i = 6; i < 16; i++) {
    bytes[i] = rng.nextInt(256);
  }
  // version 7: bytes[6] 高 4 位 = 0111
  bytes[6] = (bytes[6] & 0x0f) | 0x70;
  // variant: bytes[8] 高 2 位 = 10
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String hex(int i) => i.toRadixString(16).padLeft(2, '0');
  final s = bytes.map(hex).join();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
}

/// ISO8601 UTC 带毫秒 Z,例如 2026-03-05T06:27:03.674Z
String _iso8601Z(DateTime utc) {
  final s = utc.toIso8601String();
  if (s.endsWith('Z')) return s;
  // dart 的 toIso8601String 对 UTC 会带 Z,这里兜底
  return '${s}Z';
}

/// 文件名时间戳:本地时间,T 和 - 分隔
/// 例如 2026-03-05T16-59-22
String _fileNameTimestamp(DateTime local) {
  String p(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${p(local.month)}-${p(local.day)}T${p(local.hour)}-${p(local.minute)}-${p(local.second)}';
}
