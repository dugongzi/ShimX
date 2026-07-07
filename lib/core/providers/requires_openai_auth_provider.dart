import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shimx/core/services/app_log_service.dart';
import 'package:shimx/core/services/codex_paths.dart';

part 'requires_openai_auth_provider.g.dart';

/// `~/.codex/config.toml` 里 `[model_providers.*]` 段的 `requires_openai_auth` 字段。
///
/// - true:走 `auth.json` 里的 OpenAI 官方登录。
/// - false:不使用官方 auth,由 provider 自己的 config 提供凭据。
///
/// 状态直接反映磁盘上的真实值。改开关会立刻改写 config.toml,重启 codex 生效。
@Riverpod(keepAlive: true)
class RequiresOpenaiAuthNotifier extends _$RequiresOpenaiAuthNotifier {
  @override
  bool build() {
    Future.microtask(reload);
    return false;
  }

  Future<void> reload() async {
    state = await _readFromDisk();
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    await _writeToDisk(value);
  }

  Future<bool> _readFromDisk() async {
    try {
      final file = File(CodexPaths.configToml());
      if (!await file.exists()) return false;
      final text = await file.readAsString();
      final match =
          RegExp(r'requires_openai_auth\s*=\s*(true|false)', multiLine: true)
              .firstMatch(text);
      if (match == null) return false;
      return match.group(1) == 'true';
    } catch (e) {
      AppLogService.instance.warning(
        'RequiresOpenaiAuth',
        '读取 config.toml 失败',
        details: '$e',
      );
      return false;
    }
  }

  Future<void> _writeToDisk(bool value) async {
    try {
      final file = File(CodexPaths.configToml());
      if (!await file.exists()) {
        AppLogService.instance.warning(
          'RequiresOpenaiAuth',
          'config.toml 不存在,跳过写入',
        );
        return;
      }
      final text = await file.readAsString();
      final pattern =
          RegExp(r'requires_openai_auth\s*=\s*(true|false)', multiLine: true);
      final newLine = 'requires_openai_auth = $value';
      String next;
      if (pattern.hasMatch(text)) {
        next = text.replaceAll(pattern, newLine);
      } else {
        // config 里没这一行,插到第一个 [model_providers.*] 段末尾;
        // 找不到就直接追加到文件末尾。
        final section = RegExp(
          r'(\[model_providers\.[^\]]+\][^\[]*)',
          multiLine: true,
        );
        final m = section.firstMatch(text);
        if (m != null) {
          final before = text.substring(0, m.end);
          final after = text.substring(m.end);
          final trimmed = before.trimRight();
          next = '$trimmed\n$newLine\n$after';
        } else {
          next = '${text.trimRight()}\n$newLine\n';
        }
      }
      await file.writeAsString(next);
      AppLogService.instance.info(
        'RequiresOpenaiAuth',
        '已写入 config.toml',
        details: 'requires_openai_auth = $value',
      );
    } catch (e) {
      AppLogService.instance.error(
        'RequiresOpenaiAuth',
        '写入 config.toml 失败',
        details: '$e',
      );
    }
  }
}
