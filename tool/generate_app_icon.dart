import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart' as p;

/// 从 assets/images/icon.png 生成 Windows runner 的多分辨率 app_icon.ico。
///
/// flutter_launcher_icons 0.14.4 的 Windows 实现只产单 size(默认 48×48),
/// 在 200% 缩放屏上 Windows 不会硬拉伸,会导致桌面图标四周空一圈。
/// 这个脚本生成 16/24/32/48/64/128/256 多 size .ico,覆盖所有 DPI 档位。
///
/// 用法:`dart run tool/generate_app_icon.dart`
Future<void> main() async {
  final root = Directory.current.path;
  final source = File(p.join(root, 'assets', 'images', 'icon.png'));
  if (!await source.exists()) {
    stderr.writeln('source not found: ${source.path}');
    exit(1);
  }
  final src = decodePng(await source.readAsBytes());
  if (src == null) {
    stderr.writeln('failed to decode source png');
    exit(1);
  }

  final sizes = [16, 24, 32, 48, 64, 128, 256];
  final frames = sizes
      .map((s) => copyResize(
            src,
            width: s,
            height: s,
            interpolation: Interpolation.cubic,
          ))
      .toList();
  final out = File(p.join(root, 'windows', 'runner', 'resources', 'app_icon.ico'));
  await out.writeAsBytes(IcoEncoder().encodeImages(frames));
  stdout.writeln('wrote ${out.path} (${sizes.join("/")})');
}
