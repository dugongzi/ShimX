import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/surface_card.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/scripts/domain/models/inject_script.dart';
import 'package:shimx/features/scripts/domain/models/remote_script.dart';
import 'package:shimx/features/scripts/presentation/providers/remote_script_action_provider.dart';
import 'package:shimx/features/scripts/presentation/providers/remote_script_query_provider.dart';
import 'package:shimx/features/scripts/presentation/providers/script_query_provider.dart';

class RemoteScriptList extends ConsumerWidget {
  const RemoteScriptList({super.key, required this.localScripts});

  final List<InjectScript> localScripts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(remoteScriptCatalogProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GithubNetworkNotice(),
        SizedBox(height: AppSizes.itemGap),
        Expanded(
          child: catalogAsync.when(
            data: (catalog) {
              if (catalog.items.isEmpty) {
                return Center(child: Text(context.l10n.remoteScriptsEmpty));
              }
              return ListView.separated(
                itemCount: catalog.items.length,
                separatorBuilder: (_, __) => SizedBox(height: AppSizes.itemGap),
                itemBuilder: (context, index) {
                  return _RemoteScriptCard(
                    script: catalog.items[index],
                    localScripts: localScripts,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
          ),
        ),
      ],
    );
  }
}

class _GithubNetworkNotice extends StatelessWidget {
  const _GithubNetworkNotice();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.itemGap,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.remoteScriptsGithubHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoteScriptCard extends ConsumerWidget {
  const _RemoteScriptCard({
    required this.script,
    required this.localScripts,
  });

  final RemoteScript script;
  final List<InjectScript> localScripts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = _localScript();
    final localHash = local == null
        ? ''
        : sha256.convert(utf8.encode(local.code)).toString();
    final installed = local != null &&
        (script.sha256.isEmpty
            ? local.metadata.version == script.version
            : localHash == script.sha256.toLowerCase());
    final canRestore = local != null && !installed;
    final colorScheme = Theme.of(context).colorScheme;

    return SurfaceCard(
      child: Row(
        children: [
          Icon(
            Icons.javascript_rounded,
            size: 28,
            color: colorScheme.primary,
          ),
          SizedBox(width: AppSizes.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        script.name.isEmpty ? script.id : script.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    Text(
                      'v${script.version}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 4.ch(min: 3, max: 6)),
                Text(
                  script.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.sectionGap),
          FilledButton.tonalIcon(
            onPressed: installed ? null : () => _install(context, ref),
            icon: Icon(
              canRestore
                  ? Icons.restore_rounded
                  : installed
                      ? Icons.check_rounded
                      : Icons.download_rounded,
            ),
            label: Text(
              installed
                  ? context.l10n.scriptInstalled
                  : canRestore
                      ? context.l10n.restoreScript
                      : context.l10n.installScript,
            ),
          ),
        ],
      ),
    );
  }

  InjectScript? _localScript() {
    for (final item in localScripts) {
      if (item.id == script.fileName) return item;
    }
    return null;
  }

  Future<void> _install(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      await ref.read(installRemoteScriptProvider(script: script).future);
      if (!context.mounted) return;
      ref.invalidate(scriptsProvider);
      ref.invalidate(remoteScriptCatalogProvider);
      SmartDialog.showToast(l10n.remoteScriptInstallSuccess);
    } catch (e) {
      SmartDialog.showToast(l10n.remoteScriptInstallFailed(e.toString()));
    }
  }
}
