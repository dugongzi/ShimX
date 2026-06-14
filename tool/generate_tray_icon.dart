import 'dart:io';

import 'package:image/image.dart';
import 'package:path/path.dart' as p;

/// 从 assets/images/icon.png 生成系统托盘要用的图：
/// - tray_icon.ico  多分辨率 (16/24/32/48)，Windows LoadImage 只认 .ico
/// - tray_icon.png  32x32，macOS NSImage 用
///
/// 用法：从项目根目录跑 `dart run tool/generate_tray_icon.dart`
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

  // --- Windows ico (16/24/32/48) ---
  final icoSizes = [16, 24, 32, 48];
  final icoFrames = icoSizes
      .map((s) => copyResize(
            src,
            width: s,
            height: s,
            interpolation: Interpolation.cubic,
          ))
      .toList();
  final icoOut = File(p.join(root, 'assets', 'images', 'tray_icon.ico'));
  await icoOut.writeAsBytes(IcoEncoder().encodeImages(icoFrames));
  stdout.writeln('wrote ${icoOut.path} (${icoSizes.join("/")})');

  // --- macOS png (32x32) ---
  final pngOut = File(p.join(root, 'assets', 'images', 'tray_icon.png'));
  final pngFrame = copyResize(
    src,
    width: 32,
    height: 32,
    interpolation: Interpolation.cubic,
  );
  await pngOut.writeAsBytes(encodePng(pngFrame));
  stdout.writeln('wrote ${pngOut.path} (32x32)');
}
