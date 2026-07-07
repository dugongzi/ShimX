import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shimx/features/providers/domain/models/api_provider.dart';

part 'provider_list_state.freezed.dart';

/// 供应商列表 + 当前选中项的组合状态。
@freezed
abstract class ProviderListState with _$ProviderListState {
  const ProviderListState._();

  const factory ProviderListState({
    @Default([]) List<ApiProvider> providers,
    String? selectedId,
  }) = _ProviderListState;

  /// 当前选中的供应商（无则 null）
  ApiProvider? get selected {
    if (selectedId == null) return null;
    for (final p in providers) {
      if (p.id == selectedId) return p;
    }
    return null;
  }
}
