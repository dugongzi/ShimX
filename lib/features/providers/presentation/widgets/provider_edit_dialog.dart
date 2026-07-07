import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/core/constants/provider_protocol.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/providers/domain/models/api_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_action_provider.dart';
import 'package:shimx/features/providers/presentation/providers/provider_query_provider.dart';
import 'package:shimx/features/providers/presentation/widgets/weight_row.dart';

/// 新建 / 编辑供应商对话框。[existing] 为 null 时为新建。
class ProviderEditDialog extends HookConsumerWidget {
  const ProviderEditDialog({super.key, this.existing});

  final ApiProvider? existing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final existingProvider = existing;

    final nameCtrl = useTextEditingController(text: existingProvider?.name ?? '');
    final baseUrlCtrl =
        useTextEditingController(text: existingProvider?.baseUrl ?? '');
    final apiKeyCtrl =
        useTextEditingController(text: existingProvider?.apiKey ?? '');
    final modelCtrl = useTextEditingController();

    final models = useState<List<String>>(
      List.of(existingProvider?.models ?? const []),
    );
    final selectedModel = useState<String?>(existingProvider?.selectedModel);
    final upstreamProtocol = useState<String>(
      existingProvider?.upstreamProtocol ?? providerProtocolResponses,
    );
    final providerWeight =
        useState<int>(existingProvider?.providerWeight ?? 5);
    final modelWeight = useState<int>(existingProvider?.modelWeight ?? 5);
    final fetching = useState(false);

    void addModel() {
      final m = modelCtrl.text.trim();
      if (m.isEmpty || models.value.contains(m)) return;
      models.value = [...models.value, m];
      selectedModel.value ??= m;
      modelCtrl.clear();
    }

    void removeModel(String m) {
      final next = [...models.value]..remove(m);
      models.value = next;
      if (selectedModel.value == m) {
        selectedModel.value = next.isEmpty ? null : next.first;
      }
    }

    Future<void> fetchModels() async {
      final baseUrl = baseUrlCtrl.text.trim();
      final apiKey = apiKeyCtrl.text.trim();
      if (baseUrl.isEmpty || apiKey.isEmpty) {
        SmartDialog.showToast(l10n.providerFillFirstToast);
        return;
      }
      fetching.value = true;
      try {
        final ids = await ref.read(
          fetchProviderModelsProvider(baseUrl: baseUrl, apiKey: apiKey).future,
        );
        final next = [...models.value];
        for (final id in ids) {
          if (!next.contains(id)) next.add(id);
        }
        models.value = next;
        selectedModel.value ??= next.isEmpty ? null : next.first;
        SmartDialog.showToast(l10n.providerFetchedToast(ids.length));
      } catch (e) {
        SmartDialog.showToast(l10n.providerFetchFailedToast(e.toString()));
      } finally {
        fetching.value = false;
      }
    }

    Future<void> save() async {
      final name = nameCtrl.text.trim();
      final baseUrl = baseUrlCtrl.text.trim();
      final apiKey = apiKeyCtrl.text.trim();
      if (name.isEmpty || baseUrl.isEmpty || apiKey.isEmpty) {
        SmartDialog.showToast(l10n.providerFillAllToast);
        return;
      }
      final pickedModel = selectedModel.value;
      if (pickedModel == null || pickedModel.isEmpty) {
        SmartDialog.showToast(l10n.providerSelectModelRequiredToast);
        return;
      }
      if (existingProvider == null) {
        await ref.read(providerActionsProvider.notifier).add(
              ApiProvider(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: name,
                baseUrl: baseUrl,
                apiKey: apiKey,
                models: models.value,
                selectedModel: pickedModel,
                upstreamProtocol: upstreamProtocol.value,
                providerWeight: providerWeight.value,
                modelWeight: modelWeight.value,
              ),
            );
      } else {
        await ref.read(providerActionsProvider.notifier).update(
              existingProvider.copyWith(
                name: name,
                baseUrl: baseUrl,
                apiKey: apiKey,
                models: models.value,
                selectedModel: pickedModel,
                upstreamProtocol: upstreamProtocol.value,
                providerWeight: providerWeight.value,
                modelWeight: modelWeight.value,
              ),
            );
      }
      SmartDialog.dismiss();
      SmartDialog.showToast(l10n.providerSavedToast);
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existingProvider == null
                      ? l10n.providerEditTitleNew
                      : l10n.providerEditTitleEdit,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.providerName,
                    hintText: l10n.providerNameHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: baseUrlCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.providerBaseUrl,
                    hintText: l10n.providerBaseUrlHint,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: apiKeyCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.providerApiKey,
                    hintText: l10n.providerApiKeyHint,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.providerProtocol,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: providerProtocolResponses,
                      label: Text(l10n.providerProtocolResponses),
                    ),
                    ButtonSegment(
                      value: providerProtocolChat,
                      label: Text(l10n.providerProtocolChat),
                    ),
                    ButtonSegment(
                      value: providerProtocolMessages,
                      label: Text(l10n.providerProtocolMessages),
                    ),
                  ],
                  selected: {upstreamProtocol.value},
                  onSelectionChanged: (v) => upstreamProtocol.value = v.first,
                ),
                const SizedBox(height: 14),
                WeightRow(
                  label: l10n.providerWeight,
                  help: l10n.providerWeightHelp,
                  value: providerWeight.value,
                  onChanged: (v) => providerWeight.value = v,
                ),
                WeightRow(
                  label: l10n.modelWeight,
                  help: l10n.modelWeightHelp,
                  value: modelWeight.value,
                  onChanged: (v) => modelWeight.value = v,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.providerModels,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: fetching.value ? null : fetchModels,
                      icon: fetching.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download_outlined, size: 18),
                      label: Text(l10n.providerModelsFetch),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: modelCtrl,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: l10n.providerModelInputHint,
                        ),
                        onSubmitted: (_) => addModel(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: addModel,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                if (models.value.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in models.value)
                        InputChip(
                          label: Text(m),
                          selected: selectedModel.value == m,
                          onSelected: (_) => selectedModel.value = m,
                          onDeleted: () => removeModel(m),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => SmartDialog.dismiss(),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: save, child: Text(l10n.providerSave)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
