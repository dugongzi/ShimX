import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shim/common/widgets/section_title.dart';
import 'package:shim/common/widgets/surface_card.dart';
import 'package:shim/common/widgets/workspace_surface.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/features/skills/domain/models/codex_skill.dart';
import 'package:shim/features/skills/presentation/providers/codex_skill_action_provider.dart';
import 'package:shim/features/skills/presentation/providers/codex_skill_query_provider.dart';
import 'package:shim/l10n/app_localizations.dart';

class SkillsTab extends ConsumerStatefulWidget {
  const SkillsTab({super.key});

  @override
  ConsumerState<SkillsTab> createState() => _SkillsTabState();
}

enum _SkillProgressMode { install, refresh, import, delete }

class _SkillsTabState extends ConsumerState<SkillsTab> {
  bool _working = false;
  bool _refreshing = false;
  _SkillProgressMode? _progressMode;
  final Set<String> _busyIds = {};

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(codexSkillsProvider);
    final l10n = context.l10n;
    final showProgress =
        _working ||
        _refreshing ||
        _busyIds.isNotEmpty ||
        async.isRefreshing ||
        async.isReloading;

    return WorkspaceSurface(
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.all(AppSizes.pagePadding),
        children: [
          Row(
            children: [
              Expanded(child: SectionTitle(title: l10n.skillsTitle)),
              FilledButton.icon(
                onPressed: _working ? null : _installFolder,
                icon: const Icon(Icons.create_new_folder_rounded),
                label: Text(l10n.skillsInstallFolder),
              ),
              SizedBox(width: AppSizes.itemGap),
              OutlinedButton.icon(
                onPressed: _working ? null : _installZip,
                icon: const Icon(Icons.archive_rounded),
                label: Text(l10n.skillsInstallZip),
              ),
              IconButton(
                tooltip: l10n.refresh,
                onPressed: _refreshing ? null : _refreshSkills,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          SizedBox(height: AppSizes.itemGap),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.itemGap),
            child: Text(
              l10n.skillsHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: showProgress
                ? Padding(
                    key: const ValueKey('skills-progress'),
                    padding: EdgeInsets.only(
                      left: AppSizes.itemGap,
                      right: AppSizes.itemGap,
                      top: AppSizes.itemGap,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LinearProgressIndicator(minHeight: 2),
                        const SizedBox(height: 6),
                        Text(
                          _progressText(
                            l10n,
                            asyncRefreshing:
                                async.isRefreshing || async.isReloading,
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('skills-progress-empty')),
          ),
          SizedBox(height: AppSizes.sectionGap),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => _ErrorBox(message: error.toString()),
            data: (skills) {
              if (skills.isEmpty) {
                return _EmptySkills(
                  onInstallFolder: _working ? null : _installFolder,
                  onInstallZip: _working ? null : _installZip,
                );
              }
              final managed = skills
                  .where((skill) => skill.managedByShim)
                  .toList();
              final external = skills
                  .where((skill) => !skill.managedByShim)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (managed.isNotEmpty) ...[
                    _GroupHeader(title: l10n.skillsManagedGroup),
                    SizedBox(height: AppSizes.itemGap),
                    for (final skill in managed) ...[
                      _SkillCard(
                        key: ValueKey('managed:${skill.id}'),
                        skill: skill,
                        busy: _busyIds.contains(skill.id),
                        onImport: null,
                        onDelete: () => _deleteSkill(skill),
                      ),
                      SizedBox(height: AppSizes.itemGap),
                    ],
                    SizedBox(height: AppSizes.sectionGap),
                  ],
                  if (external.isNotEmpty) ...[
                    _GroupHeader(title: l10n.skillsExternalGroup),
                    SizedBox(height: AppSizes.itemGap),
                    for (final skill in external) ...[
                      _SkillCard(
                        key: ValueKey('external:${skill.id}'),
                        skill: skill,
                        busy: _busyIds.contains(skill.id),
                        onImport: () => _importSkill(skill),
                        onDelete: null,
                      ),
                      SizedBox(height: AppSizes.itemGap),
                    ],
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _installFolder() async {
    final l10n = context.l10n;
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null || path.isEmpty) {
      SmartDialog.showToast(l10n.skillsNoFolderSelected);
      return;
    }
    await _runInstall(
      successToast: l10n.skillsInstallSuccess,
      action: (overwriteManaged) => ref
          .read(codexSkillActionsProvider.notifier)
          .installFromFolder(
            sourcePath: path,
            overwriteManaged: overwriteManaged,
          ),
    );
  }

  Future<void> _installZip() async {
    final l10n = context.l10n;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null || path.isEmpty) {
      SmartDialog.showToast(l10n.skillsNoZipSelected);
      return;
    }

    final actions = ref.read(codexSkillActionsProvider.notifier);
    final candidates = await _guard<List<String>>(
      () => actions.listZipSkillDirectories(zipPath: path),
    );
    if (candidates == null || !mounted) return;
    final selected = candidates.length <= 1
        ? (candidates.isEmpty ? null : candidates.first)
        : await _chooseZipSkill(candidates);
    if (selected == null) return;

    await _runInstall(
      successToast: l10n.skillsInstallSuccess,
      action: (overwriteManaged) => ref
          .read(codexSkillActionsProvider.notifier)
          .installFromZip(
            zipPath: path,
            skillDirectory: selected,
            overwriteManaged: overwriteManaged,
          ),
    );
  }

  Future<void> _runInstall({
    required String successToast,
    required Future<void> Function(bool overwriteManaged) action,
  }) async {
    setState(() {
      _working = true;
      _progressMode = _SkillProgressMode.install;
    });
    try {
      await action(false);
      await _waitForSkillsRefresh();
      SmartDialog.showToast(successToast);
    } catch (error) {
      if (!_isOverwriteRequired(error) || !mounted) {
        _showError(error);
        return;
      }
      final confirmed = await _confirm(
        title: context.l10n.skillsOverwriteTitle,
        message: context.l10n.skillsOverwriteMessage,
      );
      if (!confirmed) return;
      try {
        await action(true);
        await _waitForSkillsRefresh();
        SmartDialog.showToast(successToast);
      } catch (retryError) {
        _showError(retryError);
      }
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
          _progressMode = null;
        });
      }
    }
  }

  Future<void> _importSkill(CodexSkill skill) async {
    final successToast = context.l10n.skillsImportSuccess;
    final success = await _withBusy(
      skill.id,
      _SkillProgressMode.import,
      () async {
        await ref
            .read(codexSkillActionsProvider.notifier)
            .importExisting(id: skill.id);
      },
    );
    if (success) SmartDialog.showToast(successToast);
  }

  Future<void> _deleteSkill(CodexSkill skill) async {
    final successToast = context.l10n.skillsDeleteSuccess;
    final confirmed = await _confirm(
      title: context.l10n.skillsDeleteTitle,
      message: context.l10n.skillsDeleteMessage,
    );
    if (!confirmed) return;
    final success = await _withBusy(
      skill.id,
      _SkillProgressMode.delete,
      () async {
        await ref
            .read(codexSkillActionsProvider.notifier)
            .deleteManaged(id: skill.id);
      },
    );
    if (success) SmartDialog.showToast(successToast);
  }

  Future<bool> _withBusy(
    String id,
    _SkillProgressMode mode,
    Future<void> Function() action,
  ) async {
    setState(() {
      _busyIds.add(id);
      _progressMode = mode;
    });
    try {
      await action();
      await _waitForSkillsRefresh();
      return true;
    } catch (error) {
      _showError(error);
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _busyIds.remove(id);
          if (_busyIds.isEmpty) _progressMode = null;
        });
      }
    }
  }

  Future<void> _refreshSkills() async {
    setState(() {
      _refreshing = true;
      _progressMode = _SkillProgressMode.refresh;
    });
    try {
      await _waitForSkillsRefresh();
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
          _progressMode = null;
        });
      }
    }
  }

  Future<void> _waitForSkillsRefresh() async {
    ref.invalidate(codexSkillsProvider);
    await ref.read(codexSkillsProvider.future);
  }

  Future<T?> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (error) {
      _showError(error);
      return null;
    }
  }

  Future<String?> _chooseZipSkill(List<String> candidates) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(context.l10n.skillsZipChooseTitle),
          children: [
            for (final candidate in candidates)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(candidate),
                child: Text(candidate.isEmpty ? '/' : candidate),
              ),
          ],
        );
      },
    );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.confirm),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  bool _isOverwriteRequired(Object error) {
    return error.toString().contains('需要确认覆盖');
  }

  void _showError(Object error) {
    SmartDialog.showToast(context.l10n.skillsActionFailed(error.toString()));
  }

  String _progressText(AppLocalizations l10n, {required bool asyncRefreshing}) {
    final mode = _progressMode;
    if (mode == null && asyncRefreshing) return l10n.skillsRefreshing;
    return switch (mode) {
      _SkillProgressMode.install => l10n.skillsInstalling,
      _SkillProgressMode.refresh => l10n.skillsRefreshing,
      _SkillProgressMode.import => l10n.skillsImporting,
      _SkillProgressMode.delete => l10n.skillsDeleting,
      null => l10n.skillsRefreshing,
    };
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    super.key,
    required this.skill,
    required this.busy,
    required this.onImport,
    required this.onDelete,
  });

  final CodexSkill skill;
  final bool busy;
  final VoidCallback? onImport;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final badgeColor = skill.managedByShim
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Badge(
                label: skill.managedByShim
                    ? l10n.skillsManagedBadge
                    : l10n.skillsExternalBadge,
                color: badgeColor,
              ),
              SizedBox(width: AppSizes.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name.isEmpty ? skill.id : skill.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skill.description.isEmpty
                          ? l10n.skillsNoDescription
                          : skill.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (busy)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else ...[
                if (onImport != null)
                  TextButton.icon(
                    onPressed: onImport,
                    icon: const Icon(Icons.add_link_rounded),
                    label: Text(l10n.skillsImportManaged),
                  ),
                if (onDelete != null)
                  IconButton(
                    tooltip: l10n.skillsDelete,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
              ],
            ],
          ),
          SizedBox(height: AppSizes.itemGap),
          const Divider(height: 1),
          SizedBox(height: AppSizes.itemGap),
          _InfoRow(label: 'ID', value: skill.id, copyable: true),
          const SizedBox(height: 6),
          _InfoRow(
            label: l10n.skillsPathLabel,
            value: skill.path,
            copyable: true,
          ),
          if (skill.contentHash.isNotEmpty) ...[
            const SizedBox(height: 6),
            _InfoRow(
              label: l10n.skillsHashLabel,
              value: skill.contentHash,
              copyable: true,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptySkills extends StatelessWidget {
  const _EmptySkills({
    required this.onInstallFolder,
    required this.onInstallZip,
  });

  final VoidCallback? onInstallFolder;
  final VoidCallback? onInstallZip;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.skillsEmpty,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: AppSizes.itemGap,
              runSpacing: AppSizes.itemGap,
              children: [
                FilledButton.icon(
                  onPressed: onInstallFolder,
                  icon: const Icon(Icons.create_new_folder_rounded),
                  label: Text(l10n.skillsInstallFolder),
                ),
                OutlinedButton.icon(
                  onPressed: onInstallZip,
                  icon: const Icon(Icons.archive_rounded),
                  label: Text(l10n.skillsInstallZip),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.maxLines,
  });

  final String label;
  final String value;
  final bool copyable;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            maxLines: maxLines,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontFamily: copyable ? 'monospace' : null,
            ),
          ),
        ),
        if (copyable)
          IconButton(
            tooltip: context.l10n.copy,
            iconSize: 14,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            onPressed: () async {
              final copiedToast = context.l10n.copied;
              await Clipboard.setData(ClipboardData(text: value));
              SmartDialog.showToast(copiedToast);
            },
            icon: const Icon(Icons.copy_rounded),
          ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
