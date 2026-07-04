import 'package:shim/features/plugins/domain/models/plugin_marketplace_status.dart';

abstract class PluginActionRepository {
  /// 从任意 zip 直链拉 openai/plugins 快照,释放到 codex home,写 config.toml。
  /// 常用镜像 URL 常量参考 [kJihulabZipUrl] / [kGithubZipUrl](data 层)。
  ///
  /// [onProgress] 收到 (received, total)。total 为 0 时表示服务器未提供
  /// content-length。回调频率由 dio 控制,大约每 8KB 一次,调用方自己节流。
  Future<PluginMarketplaceStatus> installFromRemoteZip({
    required String url,
    void Function(int received, int total)? onProgress,
  });

  /// 弹本地 file picker,让用户挑一个 .zip 文件。取消返回 null。
  Future<String?> pickLocalZipPath();

  /// 用户提供本地 zip 文件路径。
  Future<PluginMarketplaceStatus> installFromLocalZip({required String zipPath});

  /// 用户提供已经解压好的目录。
  Future<PluginMarketplaceStatus> installFromLocalDir({required String dirPath});
}
