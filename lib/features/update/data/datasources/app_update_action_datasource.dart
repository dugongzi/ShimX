import 'package:shimx/features/update/domain/models/app_update_release.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateActionDatasource {
  Future<void> openDownload(AppUpdateRelease release) async {
    final uri = Uri.tryParse(release.downloadUrl);
    if (uri == null || !uri.hasScheme) {
      throw StateError('Invalid download url.');
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      throw StateError('Unable to open download url.');
    }
  }
}
