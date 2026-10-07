import 'package:equatable/equatable.dart';

class AppVersionEntity extends Equatable {
  final String platform;
  final bool isForceUpdate;

  /// Only set when [isForceUpdate] is true.
  final String? minSupportedVersion;
  final String? storeUrl;
  final String? updateMessage;

  const AppVersionEntity({
    required this.platform,
    required this.isForceUpdate,
    this.minSupportedVersion,
    this.storeUrl,
    this.updateMessage,
  });

  @override
  List<Object?> get props => [
        platform,
        isForceUpdate,
        minSupportedVersion,
        storeUrl,
        updateMessage,
      ];
}
