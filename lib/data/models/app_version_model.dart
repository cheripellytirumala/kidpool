import '../../domain/entities/app_version_entity.dart';

class AppVersionModel {
  final String platform;
  final String latestVersion;
  final String minSupportedVersion;
  final String? storeUrl;
  final String? updateMessage;

  AppVersionModel({
    required this.platform,
    required this.latestVersion,
    required this.minSupportedVersion,
    this.storeUrl,
    this.updateMessage,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      platform: json['platform'] as String,
      latestVersion: json['latest_version'] as String,
      minSupportedVersion: json['min_supported_version'] as String,
      storeUrl: json['store_url'] as String?,
      updateMessage: json['update_message'] as String?,
    );
  }

  AppVersionEntity toEntity({required String currentVersion}) {
    return AppVersionEntity(
      platform: platform,
      latestVersion: latestVersion,
      minSupportedVersion: minSupportedVersion,
      storeUrl: storeUrl,
      updateMessage: updateMessage,
      isUpdateAvailable: _compareVersions(currentVersion, latestVersion) < 0,
      isForceUpdate: _compareVersions(currentVersion, minSupportedVersion) < 0,
    );
  }

  /// Compares dotted versions like "1.2.10"; ignores any "+build" suffix.
  static int _compareVersions(String a, String b) {
    List<int> parse(String v) => v
        .split('+')
        .first
        .split('.')
        .map((p) => int.tryParse(p) ?? 0)
        .toList();
    final pa = parse(a);
    final pb = parse(b);
    for (var i = 0; i < 3; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x.compareTo(y);
    }
    return 0;
  }
}
