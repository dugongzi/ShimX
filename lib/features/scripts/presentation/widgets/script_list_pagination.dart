import 'package:shimx/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class ScriptListPagination extends StatelessWidget {
  const ScriptListPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();
    final canPrev = currentPage > 1;
    final canNext = currentPage < totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: canPrev ? () => onPageSelected(currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        SizedBox(width: AppSizes.itemGap),
        for (var i = 1; i <= totalPages; i++) ...[
          _PageNumber(
            page: i,
            isCurrent: i == currentPage,
            onTap: () => onPageSelected(i),
          ),
          if (i != totalPages) SizedBox(width: AppSizes.itemGap),
        ],
        SizedBox(width: AppSizes.itemGap),
        IconButton(
          onPressed: canNext ? () => onPageSelected(currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _PageNumber extends StatelessWidget {
  const _PageNumber({
    required this.page,
    required this.isCurrent,
    required this.onTap,
  });

  final int page;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: isCurrent ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isCurrent ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$page',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isCurrent ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
