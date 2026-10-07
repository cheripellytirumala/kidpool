import '../../domain/entities/app_version_entity.dart';

/// Result of the `check_app_version` RPC. The server compares versions, so
/// all that comes back is "ok" or "force_update" plus the update details.
class AppVersionModel {
  final String platform;
  final bool isForceUpdate;
  final String? minSupportedVersion;
  final String? storeUrl;
  final String? updateMessage;

  AppVersionModel({
    required this.platform,
    required this.isForceUpdate,
    this.minSupportedVersion,
    this.storeUrl,
    this.updateMessage,
  });

  factory AppVersionModel.fromJson(
    Map<String, dynamic> json, {
    required String platform,
  }) {
    final status = json['status'] as String;
    if (status != 'ok' && status != 'force_update') {
      throw FormatException('Unknown version status: $status');
    }
    return AppVersionModel(
      platform: platform,
      isForceUpdate: status == 'force_update',
      minSupportedVersion: json['minSupportedVersion'] as String?,
      storeUrl: json['storeUrl'] as String?,
      updateMessage: json['message'] as String?,
    );
  }

  AppVersionEntity toEntity() {
    return AppVersionEntity(
      platform: platform,
      isForceUpdate: isForceUpdate,
      minSupportedVersion: minSupportedVersion,
      storeUrl: storeUrl,
      updateMessage: updateMessage,
    );
  }
}
