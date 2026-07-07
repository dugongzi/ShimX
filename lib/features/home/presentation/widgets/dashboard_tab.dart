import 'package:shimx/common/widgets/workspace_surface.dart';
import 'package:shimx/core/constants/app_sizes.dart';
import 'package:shimx/features/scripts/presentation/widgets/script_list.dart';
import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkspaceSurface(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.pagePadding),
        child: const ScriptList(),
      ),
    );
  }
}
