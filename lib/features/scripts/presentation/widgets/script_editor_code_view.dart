import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/styles/vs.dart';
import 'package:re_highlight/styles/vs2015.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/utils/js_autocomplete_prompts.dart';
import 'package:shimx/core/utils/js_code_formatter.dart';

const double _kMinFontSize = 8;
const double _kMaxFontSize = 40;
const double _kDefaultFontSize = 13;
const double _kFontStep = 1;

class ScriptEditorCodeView extends StatefulWidget {
  const ScriptEditorCodeView({
    super.key,
    required this.controller,
    this.onSave,
  });

  final CodeLineEditingController controller;

  /// Ctrl/Cmd+S 触发。re_editor 内部把 Ctrl+S 绑到 CodeShortcutSaveIntent 直接
  /// 消费了,外层 CallbackShortcuts 收不到,这里 override 转发出去。
  final VoidCallback? onSave;

  @override
  State<ScriptEditorCodeView> createState() => _ScriptEditorCodeViewState();
}

class _ScriptEditorCodeViewState extends State<ScriptEditorCodeView> {
  double _fontSize = _kDefaultFontSize;

  void _setFontSize(double next) {
    final clamped = next.clamp(_kMinFontSize, _kMaxFontSize);
    if (clamped == _fontSize) return;
    setState(() => _fontSize = clamped);
  }

  void _zoomIn() => _setFontSize(_fontSize + _kFontStep);
  void _zoomOut() => _setFontSize(_fontSize - _kFontStep);
  void _resetZoom() => _setFontSize(_kDefaultFontSize);

  /// Ctrl+Alt+L / Cmd+Alt+L 触发。整段替换文本;selection 由 controller 内部
  /// 夹到新长度,不额外还原(格式化后原光标位置意义有限)。
  void _formatCode() {
    final current = widget.controller.text;
    final formatted = JsCodeFormatter.format(current);
    if (formatted == current) return;
    widget.controller.text = formatted;
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed) {
      return;
    }
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {
      final delta = event.scrollDelta.dy;
      if (delta == 0) return;
      _setFontSize(_fontSize - delta.sign * _kFontStep);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colorScheme = Theme.of(context).colorScheme;
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.equal, control: true):
            _ZoomInIntent(),
        SingleActivator(LogicalKeyboardKey.add, control: true): _ZoomInIntent(),
        SingleActivator(LogicalKeyboardKey.numpadAdd, control: true):
            _ZoomInIntent(),
        SingleActivator(LogicalKeyboardKey.minus, control: true):
            _ZoomOutIntent(),
        SingleActivator(LogicalKeyboardKey.numpadSubtract, control: true):
            _ZoomOutIntent(),
        SingleActivator(LogicalKeyboardKey.digit0, control: true):
            _ZoomResetIntent(),
        SingleActivator(LogicalKeyboardKey.numpad0, control: true):
            _ZoomResetIntent(),
        SingleActivator(LogicalKeyboardKey.equal, meta: true): _ZoomInIntent(),
        SingleActivator(LogicalKeyboardKey.minus, meta: true): _ZoomOutIntent(),
        SingleActivator(LogicalKeyboardKey.digit0, meta: true):
            _ZoomResetIntent(),
        SingleActivator(LogicalKeyboardKey.keyL, control: true, alt: true):
            _FormatIntent(),
        SingleActivator(LogicalKeyboardKey.keyL, meta: true, alt: true):
            _FormatIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ZoomInIntent: CallbackAction<_ZoomInIntent>(
            onInvoke: (_) {
              _zoomIn();
              return null;
            },
          ),
          _ZoomOutIntent: CallbackAction<_ZoomOutIntent>(
            onInvoke: (_) {
              _zoomOut();
              return null;
            },
          ),
          _ZoomResetIntent: CallbackAction<_ZoomResetIntent>(
            onInvoke: (_) {
              _resetZoom();
              return null;
            },
          ),
          _FormatIntent: CallbackAction<_FormatIntent>(
            onInvoke: (_) {
              _formatCode();
              return null;
            },
          ),
        },
        child: Listener(
          onPointerSignal: _onPointerSignal,
          child: CodeAutocomplete(
            viewBuilder: (context, notifier, onSelected) =>
                _JsAutocompleteView(
                  notifier: notifier,
                  onSelected: onSelected,
                  colorScheme: colorScheme,
                ),
            promptsBuilder: DefaultCodeAutocompletePromptsBuilder(
              language: langJavascript,
              keywordPrompts: kJsKeywordPrompts,
              directPrompts: kJsGlobalPrompts,
              relatedPrompts: kJsMemberPrompts,
            ),
            child: CodeEditor(
              controller: widget.controller,
              wordWrap: false,
              shortcutOverrideActions: <Type, Action<Intent>>{
                CodeShortcutSaveIntent: CallbackAction<CodeShortcutSaveIntent>(
                  onInvoke: (_) {
                    widget.onSave?.call();
                    return null;
                  },
                ),
              },
              style: CodeEditorStyle(
                fontSize: _fontSize,
                fontFamily: 'Courier',
                backgroundColor: colorScheme.surface,
                codeTheme: CodeHighlightTheme(
                  languages: {
                    'javascript': CodeHighlightThemeMode(mode: langJavascript),
                  },
                  theme: isDark ? vs2015Theme : vsTheme,
                ),
              ),
              indicatorBuilder:
                  (
                    context,
                    editingController,
                    chunkController,
                    notifier,
                  ) => Row(
                    children: [
                      DefaultCodeLineNumber(
                        controller: editingController,
                        notifier: notifier,
                      ),
                    ],
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoomInIntent extends Intent {
  const _ZoomInIntent();
}

class _ZoomOutIntent extends Intent {
  const _ZoomOutIntent();
}

class _ZoomResetIntent extends Intent {
  const _ZoomResetIntent();
}

class _FormatIntent extends Intent {
  const _FormatIntent();
}

class _JsAutocompleteView extends StatefulWidget
    implements PreferredSizeWidget {
  const _JsAutocompleteView({
    required this.notifier,
    required this.onSelected,
    required this.colorScheme,
  });

  static const double _itemHeight = 24;
  static const double _width = 280;
  static const double _maxHeight = 200;

  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;
  final ColorScheme colorScheme;

  @override
  Size get preferredSize => Size(
    _width,
    math.min(_itemHeight * notifier.value.prompts.length, _maxHeight) + 2,
  );

  @override
  State<_JsAutocompleteView> createState() => _JsAutocompleteViewState();
}

class _JsAutocompleteViewState extends State<_JsAutocompleteView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible());
  }

  void _ensureVisible() {
    if (!_scrollController.hasClients) return;
    final index = widget.notifier.value.index;
    final targetTop = index * _JsAutocompleteView._itemHeight;
    final targetBottom = targetTop + _JsAutocompleteView._itemHeight;
    final offset = _scrollController.offset;
    final viewport = _scrollController.position.viewportDimension;
    if (targetTop < offset) {
      _scrollController.jumpTo(targetTop);
    } else if (targetBottom > offset + viewport) {
      _scrollController.jumpTo(targetBottom - viewport);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prompts = widget.notifier.value.prompts;
    final input = widget.notifier.value.input;
    final selectedIndex = widget.notifier.value.index;
    final scheme = widget.colorScheme;
    final bg = scheme.surfaceContainerHigh;
    final border = scheme.outlineVariant;
    final selectedBg = scheme.primary;
    final baseColor = scheme.onSurface;
    final onSelectedFg = scheme.onPrimary;

    return Container(
      constraints: BoxConstraints.loose(widget.preferredSize),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: ListView.builder(
        controller: _scrollController,
        itemExtent: _JsAutocompleteView._itemHeight,
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          final isSelected = index == selectedIndex;
          final fg = isSelected ? onSelectedFg : baseColor;
          final typeFg = isSelected
              ? onSelectedFg.withValues(alpha: 0.75)
              : scheme.onSurfaceVariant;
          return InkWell(
            onTap: () => widget.onSelected(
              widget.notifier.value.copyWith(index: index).autocomplete,
            ),
            child: Container(
              color: isSelected ? selectedBg : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerLeft,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                text: _buildSpan(prompt, input, fg, typeFg),
              ),
            ),
          );
        },
      ),
    );
  }

  InlineSpan _buildSpan(
    CodePrompt prompt,
    String input,
    Color fg,
    Color typeFg,
  ) {
    final wordStyle = TextStyle(
      fontFamily: 'Courier',
      fontSize: 13,
      color: fg,
    );
    final typeStyle = TextStyle(
      fontFamily: 'Courier',
      fontSize: 12,
      color: typeFg,
    );
    final wordSpan = _highlightWord(prompt.word, input, wordStyle);
    if (prompt is CodeFieldPrompt) {
      return TextSpan(
        children: [
          wordSpan,
          TextSpan(text: '  ${prompt.type}', style: typeStyle),
        ],
      );
    }
    if (prompt is CodeFunctionPrompt) {
      final params = prompt.parameters.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      return TextSpan(
        children: [
          wordSpan,
          TextSpan(text: '($params)', style: typeStyle),
          TextSpan(text: '  → ${prompt.type}', style: typeStyle),
        ],
      );
    }
    return wordSpan;
  }

  InlineSpan _highlightWord(String word, String input, TextStyle style) {
    if (input.isEmpty) return TextSpan(text: word, style: style);
    final lower = word.toLowerCase();
    final idx = lower.indexOf(input.toLowerCase());
    if (idx < 0) return TextSpan(text: word, style: style);
    final highlight = style.copyWith(
      fontWeight: FontWeight.bold,
      color: widget.colorScheme.secondary,
    );
    return TextSpan(
      children: [
        TextSpan(text: word.substring(0, idx), style: style),
        TextSpan(
          text: word.substring(idx, idx + input.length),
          style: highlight,
        ),
        TextSpan(text: word.substring(idx + input.length), style: style),
      ],
    );
  }
}
