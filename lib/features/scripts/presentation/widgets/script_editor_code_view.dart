import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/javascript.dart';
import 'package:re_highlight/styles/vs.dart';
import 'package:re_highlight/styles/vs2015.dart';
import 'package:shim/core/extensions/context_extensions.dart';

class ScriptEditorCodeView extends StatelessWidget {
  const ScriptEditorCodeView({super.key, required this.controller});

  final CodeLineEditingController controller;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return CodeEditor(
      controller: controller,
      wordWrap: false,
      style: CodeEditorStyle(
        fontSize: 13,
        fontFamily: 'Courier',
        backgroundColor: isDark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFFFFFFF),
        codeTheme: CodeHighlightTheme(
          languages: {
            'javascript': CodeHighlightThemeMode(mode: langJavascript),
          },
          theme: isDark ? vs2015Theme : vsTheme,
        ),
      ),
      indicatorBuilder: (
        context,
        editingController,
        chunkController,
        notifier,
      ) {
        return Row(
          children: [
            DefaultCodeLineNumber(
              controller: editingController,
              notifier: notifier,
            ),
          ],
        );
      },
    );
  }
}
