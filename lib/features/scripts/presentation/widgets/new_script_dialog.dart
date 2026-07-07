import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shimx/core/extensions/context_extensions.dart';

class NewScriptDialog {
  NewScriptDialog._();

  /// 返回用户输入的名字(未含 .js);取消返回 null。
  static Future<String?> show(
    BuildContext context,
    Set<String> existingIds,
  ) {
    return showDialog<String>(
      context: context,
      builder: (_) => _NewScriptDialogContent(existingIds: existingIds),
    );
  }
}

class _NewScriptDialogContent extends HookWidget {
  const _NewScriptDialogContent({required this.existingIds});

  final Set<String> existingIds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = useTextEditingController();
    final error = useState<String?>(null);

    String? validate(String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return l10n.scriptNameRequired;
      final withExt = trimmed.endsWith('.js') ? trimmed : '$trimmed.js';
      if (existingIds.contains(withExt.toLowerCase())) {
        return l10n.scriptNameExists;
      }
      if (RegExp(r'[\\/:*?"<>|]').hasMatch(trimmed)) {
        return l10n.scriptNameInvalid;
      }
      return null;
    }

    void submit() {
      final e = validate(controller.text);
      if (e != null) {
        error.value = e;
        return;
      }
      Navigator.of(context).pop(controller.text.trim());
    }

    return AlertDialog(
      title: Text(l10n.newScript),
      content: SizedBox(
        width: 360,
        child: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (_) => submit(),
          onChanged: (v) {
            if (error.value != null) error.value = validate(v);
          },
          decoration: InputDecoration(
            labelText: l10n.scriptNameHint,
            suffixText: '.js',
            errorText: error.value,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: submit, child: Text(l10n.create)),
      ],
    );
  }
}
