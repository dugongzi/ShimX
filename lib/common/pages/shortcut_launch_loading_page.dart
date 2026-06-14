import 'package:flutter/material.dart';
import 'package:shim/common/widgets/app_background.dart';
import 'package:shim/core/constants/app_sizes.dart';
import 'package:shim/core/extensions/context_extensions.dart';

class ShortcutLaunchLoadingPage extends StatelessWidget {
  const ShortcutLaunchLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.pagePadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 44.cr(min: 36, max: 52),
                      height: 44.cr(min: 36, max: 52),
                      child: CircularProgressIndicator(
                        strokeWidth: 3.5,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: AppSizes.sectionGap),
                    Text(
                      context.l10n.launchingCodex,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
