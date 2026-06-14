import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'launch_args_provider.g.dart';

/// app 启动时由 main(args) 通过 ProviderScope.overrides 注入。
@Riverpod(keepAlive: true)
List<String> launchArgs(Ref ref) => const [];
