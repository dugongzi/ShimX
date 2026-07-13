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
      // 只读顶层 model_provider 指名的那一段。多 provider 时不能靠"文件里第一个
      // requires_openai_auth"—— 那可能是别的 provider 的。
      final providerId = _extractActiveModelProviderId(text);
      if (providerId == null) return false;
      final section = _extractProviderSection(text, providerId);
      if (section == null) return false;
      final match = RegExp(
        r'^\s*requires_openai_auth\s*=\s*(true|false)',
        multiLine: true,
      ).firstMatch(section);
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
      final providerId = _extractActiveModelProviderId(text);
      if (providerId == null) {
        AppLogService.instance.warning(
          'RequiresOpenaiAuth',
          '未定位到顶层 model_provider,跳过写入',
        );
        return;
      }
      final range = _findProviderSectionRange(text, providerId);
      if (range == null) {
        AppLogService.instance.warning(
          'RequiresOpenaiAuth',
          '未找到 [model_providers.$providerId] 段,跳过写入',
        );
        return;
      }
      final sectionText = text.substring(range.start, range.end);
      final newLine = 'requires_openai_auth = $value';
      final lineRe = RegExp(
        r'^[ \t]*requires_openai_auth\s*=\s*(true|false)[ \t]*\r?\n?',
        multiLine: true,
      );
      String newSection;
      if (lineRe.hasMatch(sectionText)) {
        // 已有:原地替换,保留原换行,不影响 section 边界
        newSection = sectionText.replaceFirstMapped(lineRe, (m) {
          // 保留匹配末尾的换行(如果有),让下一行不被吃掉
          final tail = m.group(0)!.endsWith('\n') ? '\n' : '';
          return '$newLine$tail';
        });
      } else {
        // 没有:插到 section 末尾的最后一个非空行之后,不改 section 边界
        // 之前的实现把新行拼到 section.end 之外,导致跟下一段 [xxx] 挤在一起。
        // 这里改成"在 section 内部"追加,section.end 本身保留原有的换行/边界。
        final trimmedRight = sectionText.replaceFirst(RegExp(r'\s+$'), '');
        final trailing = sectionText.substring(trimmedRight.length);
        newSection = '$trimmedRight\n$newLine$trailing';
        if (!newSection.endsWith('\n')) newSection = '$newSection\n';
      }
      final next =
          text.substring(0, range.start) + newSection + text.substring(range.end);
      await file.writeAsString(next);
      AppLogService.instance.info(
        'RequiresOpenaiAuth',
        '已写入 config.toml',
        details: 'provider=$providerId requires_openai_auth = $value',
      );
    } catch (e) {
      AppLogService.instance.error(
        'RequiresOpenaiAuth',
        '写入 config.toml 失败',
        details: '$e',
      );
    }
  }

  /// 从 config 顶层抓 `model_provider = "xxx"`,决定"哪段是当前生效的 provider"。
  /// 顶层 = 不在任何 [xxx] section 之内。TOML 语义上 section 之前的裸键才是顶层键。
  String? _extractActiveModelProviderId(String text) {
    final firstSection = RegExp(r'^\s*\[', multiLine: true).firstMatch(text);
    final topLevel =
        firstSection == null ? text : text.substring(0, firstSection.start);
    final m = RegExp(
      r'''^\s*model_provider\s*=\s*['"]([^'"]+)['"]''',
      multiLine: true,
    ).firstMatch(topLevel);
    return m?.group(1);
  }

  /// 抽出 `[model_providers.<id>]` 段的文本(从 header 行开始到下一个 `[xxx]` 前)。
  String? _extractProviderSection(String text, String id) {
    final range = _findProviderSectionRange(text, id);
    if (range == null) return null;
    return text.substring(range.start, range.end);
  }

  /// 定位 `[model_providers.<id>]` 段在文件里的字符范围。
  /// start = header 行行首,end = 下一个 `[xxx]` header 行行首(或文件末尾)。
  _Range? _findProviderSectionRange(String text, String id) {
    // header 里 id 可以带 . 或直接名字,允许可选的 . 语法(TOML 允许 dotted key)。
    final headerRe = RegExp(
      '^\\s*\\[model_providers\\.${RegExp.escape(id)}\\]\\s*\$',
      multiLine: true,
    );
    final header = headerRe.firstMatch(text);
    if (header == null) return null;
    // 从 header 结束的下一个字符往后找,遇到下一个 header ("^[") 就是段尾
    final afterHeaderStart = header.end;
    final nextHeader = RegExp(r'^\s*\[', multiLine: true)
        .firstMatch(text.substring(afterHeaderStart));
    final end = nextHeader == null
        ? text.length
        : afterHeaderStart + nextHeader.start;
    return _Range(header.start, end);
  }
}

class _Range {
  const _Range(this.start, this.end);
  final int start;
  final int end;
}
