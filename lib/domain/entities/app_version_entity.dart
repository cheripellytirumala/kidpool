import 'package:equatable/equatable.dart';

class AppVersionEntity extends Equatable {
  final String platform;
  final String latestVersion;
  final String minSupportedVersion;
  final String? storeUrl;
  final String? updateMessage;
  final bool isUpdateAvailable;
  final bool isForceUpdate;

  const AppVersionEntity({
    required this.platform,
    required this.latestVersion,
    required this.minSupportedVersion,
    this.storeUrl,
    this.updateMessage,
    required this.isUpdateAvailable,
    required this.isForceUpdate,
  });

  @override
  List<Object?> get props => [
        platform,
        latestVersion,
        minSupportedVersion,
        storeUrl,
        updateMessage,
        isUpdateAvailable,
        isForceUpdate,
      ];
}
