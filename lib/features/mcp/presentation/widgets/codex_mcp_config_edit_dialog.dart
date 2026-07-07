import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/core/utils/mcp_config_body.dart';
import 'package:shimx/features/mcp/domain/models/codex_mcp_config.dart';
import 'package:shimx/features/mcp/presentation/providers/codex_mcp_config_action_provider.dart';
import 'package:shimx/features/mcp/presentation/widgets/mcp_dialog_field.dart';
import 'package:shimx/features/mcp/presentation/widgets/mcp_enabled_toggle.dart';

/// codex MCP 配置 新建 / 编辑对话框。
/// 由 [SmartDialog.show] 调起;[existing] 为 null 时为新建。
class CodexMcpConfigEditDialog extends HookConsumerWidget {
  const CodexMcpConfigEditDialog({super.key, this.existing});

  final CodexMcpConfig? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final existingConfig = existing;

    final idCtrl = useTextEditingController(text: existingConfig?.id ?? '');
    final bodyCtrl = useTextEditingController(
      text: existingConfig?.bodyText ?? defaultMcpConfigBody,
    );
    final enabled = useState(existingConfig?.enabled ?? true);
    final saving = useState(false);

    Future<void> save() async {
      final id = idCtrl.text.trim();
      final bodyText = bodyCtrl.text.trim();
      if (id.isEmpty || bodyText.isEmpty) {
        SmartDialog.showToast(l10n.mcpConfigFillRequiredToast);
        return;
      }
      saving.value = true;
      try {
        await ref.read(codexMcpConfigActionsProvider.notifier).save(
              CodexMcpConfig(
                id: id,
                kind: CodexMcpConfigKind.mcpServer,
                name: id,
                description: firstNonEmptyLine(bodyText),
                bodyText: bodyText,
                enabled: enabled.value,
                managedByShimX: true,
                readOnly: false,
              ),
            );
        SmartDialog.dismiss();
        SmartDialog.showToast(l10n.providerSavedToast);
      } catch (error) {
        SmartDialog.showToast(error.toString());
      } finally {
        saving.value = false;
      }
    }

    final title = existingConfig == null
        ? l10n.mcpConfigDialogTitleNew
        : l10n.mcpConfigDialogTitleEdit;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Material(
          color: colorScheme.surface,
          elevation: 18,
          shadowColor: Colors.black.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.cancel,
                        onPressed: saving.value ? null : SmartDialog.dismiss,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  McpDialogField(
                    label: l10n.mcpConfigIdLabel,
                    child: TextField(
                      controller: idCtrl,
                      enabled: existingConfig == null && !saving.value,
                      style: const TextStyle(fontSize: 14),
                      decoration: mcpDialogInputDecoration(
                        context,
                        hintText: l10n.mcpConfigIdHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  McpDialogField(
                    label: l10n.mcpConfigBodyContentLabel,
                    child: TextField(
                      controller: bodyCtrl,
                      enabled: !saving.value,
                      minLines: 8,
                      maxLines: 12,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.45,
                      ),
                      decoration: mcpDialogInputDecoration(
                        context,
                        helperText: l10n.mcpConfigBodyHelper,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  McpEnabledToggle(
                    label: l10n.mcpConfigEnabledLabel,
                    value: enabled.value,
                    enabled: !saving.value,
                    onChanged: (v) => enabled.value = v,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: saving.value ? null : SmartDialog.dismiss,
                        child: Text(l10n.cancel),
                      ),
                      SizedBox(width: AppSizes.itemGap),
                      FilledButton.icon(
                        onPressed: saving.value ? null : save,
                        icon: saving.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(l10n.providerSave),
                      ),
                    ],
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
