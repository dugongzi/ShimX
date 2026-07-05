/// 简易 JavaScript 代码排版。不做换行/断行(那要真语法树),只做:
///   * 按 `{}[]()` 深度重排每行开头缩进为 2 空格
///   * 折叠 ≥3 连续空行 → 1 空行
///   * 去行尾空白 + 保证末尾单换行
///   * 单/双引号、反引号模板串、`//` 与 `/* */` 注释、正则字面量里的括号不参与深度
///
/// 边缘不覆盖:switch/case、多行三元、含 `?:` 换行、`if () {...}` 单行块内的 `}`
/// 收尾都可能算错;但对绝大多数用户脚本足够用。碰到反常 case,不改动比乱改好。
library;

class JsCodeFormatter {
  const JsCodeFormatter._();

  static const _indentUnit = '  ';

  /// 格式化整段代码。原文空/只有空白时返回原文,避免误伤空文件。
  static String format(String source) {
    if (source.trim().isEmpty) return source;

    final lines = source.split('\n');
    final out = <String>[];
    int depth = 0;
    int blank = 0;
    // 跨行状态:块注释、模板字符串
    bool inBlockComment = false;
    bool inTemplate = false;

    for (final raw in lines) {
      final line = raw.replaceFirst(RegExp(r'\s+$'), '');
      final trimmed = line.trimLeft();

      if (trimmed.isEmpty) {
        blank++;
        if (blank <= 1) out.add('');
        continue;
      }
      blank = 0;

      // 行首若是闭括号,先减深度再输出,才能对齐到开括号那层
      final leadingCloses = _countLeadingClosers(trimmed);
      final effectiveDepth = (depth - leadingCloses).clamp(0, 1 << 30);
      out.add(_indentUnit * effectiveDepth + trimmed);

      // 再扫整行更新深度和跨行状态
      final scan = _scanLine(
        trimmed,
        inBlockComment: inBlockComment,
        inTemplate: inTemplate,
      );
      inBlockComment = scan.inBlockComment;
      inTemplate = scan.inTemplate;
      depth = (depth + scan.deltaDepth).clamp(0, 1 << 30);
    }

    final joined = out.join('\n');
    return joined.endsWith('\n') ? joined : '$joined\n';
  }

  /// 行首连续 `}])` 的个数,用来把闭括号"回缩"到开括号那层。
  static int _countLeadingClosers(String s) {
    var n = 0;
    for (final r in s.runes) {
      final ch = String.fromCharCode(r);
      if (ch == '}' || ch == ']' || ch == ')') {
        n++;
      } else {
        break;
      }
    }
    return n;
  }

  /// 扫描一行,产出深度增量和跨行状态。参数是已 trimLeft 的行。
  static _LineScan _scanLine(
    String line, {
    required bool inBlockComment,
    required bool inTemplate,
  }) {
    var depth = 0;
    var block = inBlockComment;
    var template = inTemplate;
    String? quote; // 单/双引号中的当前字符
    var i = 0;

    while (i < line.length) {
      final c = line[i];
      final next = i + 1 < line.length ? line[i + 1] : '';

      if (block) {
        if (c == '*' && next == '/') {
          block = false;
          i += 2;
          continue;
        }
        i++;
        continue;
      }
      if (template) {
        if (c == r'\' && next.isNotEmpty) {
          i += 2;
          continue;
        }
        if (c == '`') {
          template = false;
          i++;
          continue;
        }
        i++;
        continue;
      }
      if (quote != null) {
        if (c == r'\' && next.isNotEmpty) {
          i += 2;
          continue;
        }
        if (c == quote) {
          quote = null;
        }
        i++;
        continue;
      }

      if (c == '/' && next == '/') {
        break; // 行注释,后面整行忽略
      }
      if (c == '/' && next == '*') {
        block = true;
        i += 2;
        continue;
      }
      if (c == '`') {
        template = true;
        i++;
        continue;
      }
      if (c == '"' || c == "'") {
        quote = c;
        i++;
        continue;
      }

      if (c == '{' || c == '[' || c == '(') {
        depth++;
      } else if (c == '}' || c == ']' || c == ')') {
        depth--;
      }
      i++;
    }

    return _LineScan(
      deltaDepth: depth,
      inBlockComment: block,
      inTemplate: template,
    );
  }
}

class _LineScan {
  const _LineScan({
    required this.deltaDepth,
    required this.inBlockComment,
    required this.inTemplate,
  });

  final int deltaDepth;
  final bool inBlockComment;
  final bool inTemplate;
}
