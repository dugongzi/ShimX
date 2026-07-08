import 'dart:ffi';
import 'dart:io';

import 'package:shimx/features/update/domain/models/app_update_system.dart';

class AppUpdatePlatformDatasource {
  AppUpdateSystem? currentSystem() {
    if (Platform.isWindows) return AppUpdateSystem.win;
    if (Platform.isMacOS) {
      return Abi.current() == Abi.macosArm64
          ? AppUpdateSystem.macM
          : AppUpdateSystem.macI;
    }
    return null;
  }
}
