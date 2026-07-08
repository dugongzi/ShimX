/// ShimX Admin 后台约定的客户端系统枚举。
enum AppUpdateSystem {
  win('win', 'Windows'),
  macM('mac_m', 'macOS Apple Silicon'),
  macI('mac_i', 'macOS Intel');

  const AppUpdateSystem(this.code, this.label);

  final String code;
  final String label;

  static AppUpdateSystem? fromCode(String? code) {
    return switch (code) {
      'win' => AppUpdateSystem.win,
      'mac_m' => AppUpdateSystem.macM,
      'mac_i' => AppUpdateSystem.macI,
      _ => null,
    };
  }
}
