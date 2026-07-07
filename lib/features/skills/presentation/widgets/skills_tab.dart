import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimx/common/widgets/section_title.dart';
import 'package:shimx/common/widgets/workspace_surface.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/core/constants/skill_progress_mode.dart';
import 'package:shimx/core/extensions/context_extensions.dart';
import 'package:shimx/features/skills/domain/models/codex_skill.dart';
import 'package:shimx/features/skills/domain/models/skill_overwrite_required_exception.dart';
import 'package:shimx/features/skills/presentation/providers/codex_skill_action_provider.dart';
import 'package:shimx/features/skills/presentation/providers/codex_skill_query_provider.dart';
import 'package:shimx/features/skills/presentation/widgets/empty_skills.dart';
import 'package:shimx/features/skills/presentation/widgets/skill_card.dart';
import 'package:shimx/features/skills/presentation/widgets/skill_group_header.dart';
import 'package:shimx/features/skills/presentation/widgets/skills_error_box.dart';
import 'package:shimx/features/skills/presentation/widgets/skills_progress_bar.dart';

class SkillsTab extends HookConsumerWidget {
  const SkillsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(codexSkillsProvider);
    final l10n = context.l10n;

    final working = useState(false);
    final refreshing = useState(false);
    final progressMode = useState<SkillProgressMode?>(null);
    final busyIds = useState<Set<String>>(const {});

    final showProgress = working.value ||
        refreshing.value ||
        busyIds.value.isNotEmpty ||
        async.isRefreshing ||
        async.isReloading;

    Future<void> waitForRefresh() async {
      ref.invalidate(codexSkillsProvider);
      await ref.read(codexSkillsProvider.future);
    }

    void showError(Object error) {
      SmartDialog.showToast(l10n.skillsActionFailed(error.toString()));
    }

    Future<bool> confirm({required String title, required String message}) async {
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

    Future<String?> chooseZipSkill(List<String> candidates) {
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

    Future<void> runInstall({
      required String successToast,
      required Future<void> Function(bool overwriteManaged) action,
    }) async {
      working.value = true;
      progressMode.value = SkillProgressMode.install;
      try {
        await action(false);
        await waitForRefresh();
        SmartDialog.showToast(successToast);
      } on SkillOverwriteRequiredException {
        final confirmed = await confirm(
          title: l10n.skillsOverwriteTitle,
          message: l10n.skillsOverwriteMessage,
        );
        if (!confirmed) return;
        try {
          await action(true);
          await waitForRefresh();
          SmartDialog.showToast(successToast);
        } catch (retryError) {
          showError(retryError);
        }
      } catch (error) {
        showError(error);
      } finally {
        working.value = false;
        progressMode.value = null;
      }
    }

    Future<void> installFolder() async {
      final path = await FilePicker.platform.getDirectoryPath();
      if (path == null || path.isEmpty) {
        SmartDialog.showToast(l10n.skillsNoFolderSelected);
        return;
      }
      await runInstall(
        successToast: l10n.skillsInstallSuccess,
        action: (overwriteManaged) => ref
            .read(codexSkillActionsProvider.notifier)
            .installFromFolder(
              sourcePath: path,
              overwriteManaged: overwriteManaged,
            ),
      );
    }

    Future<void> installZip() async {
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
      final List<String> candidates;
      try {
        candidates = await actions.listZipSkillDirectories(zipPath: path);
      } catch (error) {
        showError(error);
        return;
      }
      final selected = candidates.length <= 1
          ? (candidates.isEmpty ? null : candidates.first)
          : await chooseZipSkill(candidates);
      if (selected == null) return;

      await runInstall(
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

    Future<bool> withBusy(
      String id,
      SkillProgressMode mode,
      Future<void> Function() action,
    ) async {
      busyIds.value = {...busyIds.value, id};
      progressMode.value = mode;
      try {
        await action();
        await waitForRefresh();
        return true;
      } catch (error) {
        showError(error);
        return false;
      } finally {
        final next = {...busyIds.value}..remove(id);
        busyIds.value = next;
        if (next.isEmpty) progressMode.value = null;
      }
    }

    Future<void> importSkill(CodexSkill skill) async {
      final successToast = l10n.skillsImportSuccess;
      final success = await withBusy(skill.id, SkillProgressMode.import, () async {
        await ref
            .read(codexSkillActionsProvider.notifier)
            .importExisting(id: skill.id);
      });
      if (success) SmartDialog.showToast(successToast);
    }

    Future<void> deleteSkill(CodexSkill skill) async {
      final successToast = l10n.skillsDeleteSuccess;
      final confirmed = await confirm(
        title: l10n.skillsDeleteTitle,
        message: l10n.skillsDeleteMessage,
      );
      if (!confirmed) return;
      final success = await withBusy(skill.id, SkillProgressMode.delete, () async {
        await ref
            .read(codexSkillActionsProvider.notifier)
            .deleteManaged(id: skill.id);
      });
      if (success) SmartDialog.showToast(successToast);
    }

    Future<void> refreshSkills() async {
      refreshing.value = true;
      progressMode.value = SkillProgressMode.refresh;
      try {
        await waitForRefresh();
      } catch (error) {
        showError(error);
      } finally {
        refreshing.value = false;
        progressMode.value = null;
      }
    }

    return WorkspaceSurface(
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.all(AppSizes.pagePadding),
        children: [
          Row(
            children: [
              Expanded(child: SectionTitle(title: l10n.skillsTitle)),
              FilledButton.icon(
                onPressed: working.value ? null : installFolder,
                icon: const Icon(Icons.create_new_folder_rounded),
                label: Text(l10n.skillsInstallFolder),
              ),
              SizedBox(width: AppSizes.itemGap),
              OutlinedButton.icon(
                onPressed: working.value ? null : installZip,
                icon: const Icon(Icons.archive_rounded),
                label: Text(l10n.skillsInstallZip),
              ),
              IconButton(
                tooltip: l10n.refresh,
                onPressed: refreshing.value ? null : refreshSkills,
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
          SkillsProgressBar(
            show: showProgress,
            mode: progressMode.value,
            asyncRefreshing: async.isRefreshing || async.isReloading,
          ),
          SizedBox(height: AppSizes.sectionGap),
          async.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => SkillsErrorBox(message: error.toString()),
            data: (skills) {
              if (skills.isEmpty) {
                return EmptySkills(
                  onInstallFolder: working.value ? null : installFolder,
                  onInstallZip: working.value ? null : installZip,
                );
              }
              final managed =
                  skills.where((skill) => skill.managedByShimX).toList();
              final external =
                  skills.where((skill) => !skill.managedByShimX).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (managed.isNotEmpty) ...[
                    SkillGroupHeader(title: l10n.skillsManagedGroup),
                    SizedBox(height: AppSizes.itemGap),
                    for (final skill in managed) ...[
                      SkillCard(
                        key: ValueKey('managed:${skill.id}'),
                        skill: skill,
                        busy: busyIds.value.contains(skill.id),
                        onImport: null,
                        onDelete: () => deleteSkill(skill),
                      ),
                      SizedBox(height: AppSizes.itemGap),
                    ],
                    SizedBox(height: AppSizes.sectionGap),
                  ],
                  if (external.isNotEmpty) ...[
                    SkillGroupHeader(title: l10n.skillsExternalGroup),
                    SizedBox(height: AppSizes.itemGap),
                    for (final skill in external) ...[
                      SkillCard(
                        key: ValueKey('external:${skill.id}'),
                        skill: skill,
                        busy: busyIds.value.contains(skill.id),
                        onImport: () => importSkill(skill),
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
}
