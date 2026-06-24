import 'dart:async';

import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';
import 'package:shim/core/services/bridge_service.dart';
import 'package:shim/core/services/cdp_service.dart';
import 'package:shim/core/services/codex_launcher_service.dart';
import 'package:shim/core/services/local_proxy_service.dart';
import 'package:shim/features/claude_session/presentation/providers/claude_session_query_provider.dart';
import 'package:shim/features/codex_session/presentation/providers/codex_session_action_provider.dart';
import 'package:shim/features/codex_session/presentation/providers/codex_session_export_provider.dart';
import 'package:shim/features/codex_session/presentation/providers/codex_session_query_provider.dart';
import 'package:shim/features/home/presentation/providers/inject_action_provider.dart';
import 'package:shim/features/mcp/presentation/providers/claude_bridge_provider.dart';
import 'package:shim/features/providers/presentation/providers/auto_switch_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_action_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_health_provider.dart';
import 'package:shim/features/providers/presentation/providers/provider_query_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomeSidebar extends StatelessWidget {
  const HomeSidebar({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: AppSizes.sidebarWidth,
      child: Container(
        padding: EdgeInsets.all(AppSizes.itemGap),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(
            alpha: context.isDark ? 0.68 : 0.76,
          ),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius + 4),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(
              alpha: context.isDark ? 0.18 : 0.42,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: context.isDark ? 0.18 : 0.06,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SidebarBrand(title: title),
                  SizedBox(height: AppSizes.sectionGap),
                ],
              ),
            ),
            // 导航 tab 列表
            SliverList.separated(
              itemCount: children.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: AppSizes.itemGap),
              itemBuilder: (context, index) => children[index],
            ),
            // 底部按钮组：窗口够高时贴底，矮时整体可滚不溢出
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(height: AppSizes.sectionGap),
                  const SidebarActionIconsRow(debugPort: 9229),
                  SizedBox(height: AppSizes.itemGap),
                  const SidebarStatus(),
                  SizedBox(height: AppSizes.itemGap),
                  const ProxyStatus(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarBrand extends StatelessWidget {
  const SidebarBrand({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.itemGap,
        vertical: AppSizes.itemGap,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/icon.png',
            width: 34.cr(min: 30, max: 38),
            height: 34.cr(min: 30, max: 38),
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10.cw(min: 8, max: 12)),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarActionIconsRow extends ConsumerWidget {
  const SidebarActionIconsRow({super.key, required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(10.cw(min: 8, max: 12)),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: context.isDark ? 0.10 : 0.42,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _OpenInspectorIcon(debugPort: debugPort),
          _ReloadCodexIcon(debugPort: debugPort),
          _InjectIcon(debugPort: debugPort),
        ],
      ),
    );
  }
}

class _OpenInspectorIcon extends HookConsumerWidget {
  const _OpenInspectorIcon({required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpening = useState(false);
    final l10n = context.l10n;

    return IconButton(
      tooltip: l10n.openInspector,
      onPressed: isOpening.value
          ? null
          : () async {
              isOpening.value = true;
              try {
                await ref
                    .read(openInspectorProvider(debugPort: debugPort).future);
              } catch (e) {
                SmartDialog.showToast(l10n.openInspectorFailed(e.toString()));
              } finally {
                isOpening.value = false;
              }
            },
      icon: isOpening.value
          ? SizedBox(
              width: 18.cr(min: 16, max: 20),
              height: 18.cr(min: 16, max: 20),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.terminal_rounded),
    );
  }
}

class _ReloadCodexIcon extends HookConsumerWidget {
  const _ReloadCodexIcon({required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReloading = useState(false);

    final l10n = context.l10n;
    return IconButton(
      tooltip: l10n.refreshCodex,
      onPressed: isReloading.value
          ? null
          : () async {
              isReloading.value = true;
              try {
                final repo = ref.read(injectActionRepositoryProvider);
                final cdp = ref.read(cdpServiceProvider);
                final bridge = ref.read(bridgeServiceProvider);
                ref.read(codexSessionRouteRegistrationProvider);
                ref.read(codexSessionActionRouteRegistrationProvider);
                ref.read(codexSessionExportRouteRegistrationProvider);
                ref.read(claudeSessionRouteRegistrationProvider);
                ref.read(providerRouteRegistrationProvider);
                ref.read(providerHealthRouteRegistrationProvider);
                ref.read(autoSwitchRouteRegistrationProvider);
                ref.read(providerActionRouteRegistrationProvider);
                ref.read(claudeBridgeRouteRegistrationProvider);

                await cdp.connect(debugPort);
                await cdp.reloadPage();
                await Future<void>.delayed(const Duration(milliseconds: 800));
                final script = await repo.loadInjectScript();
                await bridge.install(documentScripts: [script]);
                SmartDialog.showToast(l10n.codexRefreshedToast);
              } catch (error) {
                SmartDialog.showToast(l10n.codexRefreshFailedToast(error.toString()));
              } finally {
                isReloading.value = false;
              }
            },
      icon: isReloading.value
          ? SizedBox(
              width: 18.cr(min: 16, max: 20),
              height: 18.cr(min: 16, max: 20),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh_rounded),
    );
  }
}

class _InjectIcon extends HookConsumerWidget {
  const _InjectIcon({required this.debugPort});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInjecting = useState(false);
    final l10n = context.l10n;

    return IconButton(
      tooltip: l10n.inject,
      onPressed: isInjecting.value
          ? null
          : () async {
              isInjecting.value = true;
              try {
                ref.invalidate(launchAndInjectProvider(debugPort: debugPort));
                await ref
                    .read(launchAndInjectProvider(debugPort: debugPort).future);
                SmartDialog.showToast(l10n.injectSuccess);
              } on CodexNotInstalledException {
                SmartDialog.showToast(l10n.codexNotInstalled);
              } catch (e) {
                SmartDialog.showToast(l10n.launchFailed(e.toString()));
              } finally {
                isInjecting.value = false;
              }
            },
      icon: isInjecting.value
          ? SizedBox(
              width: 18.cr(min: 16, max: 20),
              height: 18.cr(min: 16, max: 20),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : const Icon(Icons.play_arrow_rounded),
    );
  }
}

class SidebarStatus extends HookConsumerWidget {
  const SidebarStatus({super.key, this.debugPort = 9229});

  final int debugPort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final asyncStatus =
        ref.watch(isDebugPortAliveProvider(debugPort: debugPort));

    final pollInterval = asyncStatus.isLoading
        ? const Duration(seconds: 1)
        : asyncStatus.value == true
            ? const Duration(seconds: 10)
            : const Duration(seconds: 2);

    useEffect(() {
      final timer = Timer.periodic(pollInterval, (_) {
        ref.invalidate(isDebugPortAliveProvider(debugPort: debugPort));
      });
      return timer.cancel;
    }, [debugPort, pollInterval]);

    final Color dotColor;
    final String text;
    if (asyncStatus.isLoading) {
      dotColor = colorScheme.onSurfaceVariant;
      text = context.l10n.checkingStatus;
    } else if (asyncStatus.value == true) {
      dotColor = Colors.green;
      text = context.l10n.codexConnected;
    } else {
      dotColor = Colors.red;
      text = context.l10n.codexDisconnected;
    }

    return Container(
      padding: EdgeInsets.all(10.cw(min: 8, max: 12)),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(
          alpha: context.isDark ? 0.10 : 0.42,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSizes.itemGap),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.refresh,
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => ref.invalidate(
              isDebugPortAliveProvider(debugPort: debugPort),
            ),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class ProxyStatus extends ConsumerWidget {
  const ProxyStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final proxyConfig = ref.watch(proxyConfigProvider).value;
    final runningPortListenable = ref.watch(localProxyRunningPortProvider);

    return ValueListenableBuilder<int?>(
      valueListenable: runningPortListenable,
      builder: (context, runningPort, _) {
        final enabled = proxyConfig?.enabled == true;
        final running = runningPort != null;
        final dotColor = running
            ? Colors.green
            : enabled
                ? Colors.orange
                : colorScheme.onSurfaceVariant;
        final l10n = context.l10n;
        final text = running
            ? l10n.proxyRunningOnPort(runningPort)
            : enabled
                ? l10n.proxyEnabledOnPort(proxyConfig?.port ?? 8787)
                : l10n.proxyDisabled;

        return Container(
          padding: EdgeInsets.all(10.cw(min: 8, max: 12)),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(
              alpha: context.isDark ? 0.10 : 0.42,
            ),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: AppSizes.itemGap),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
