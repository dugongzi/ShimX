import 'package:shim/features/plugins/domain/models/plugin_marketplace_status.dart';

abstract class PluginActionRepository {
  /// 从 GitHub `openai/plugins` 拉 zip,释放到 codex home,写 config.toml。
  /// 返回安装后的状态。
  ///
  /// [onProgress] 收到 (received, total)。total 为 0 时表示服务器未提供
  /// content-length。回调频率由 dio 控制,大约每 8KB 一次,调用方自己节流。
  Future<PluginMarketplaceStatus> installFromGithub({
    void Function(int received, int total)? onProgress,
  });

  /// 用户提供本地 zip 文件路径。
  Future<PluginMarketplaceStatus> installFromLocalZip({required String zipPath});

  /// 用户提供已经解压好的目录。
  Future<PluginMarketplaceStatus> installFromLocalDir({required String dirPath});
}
