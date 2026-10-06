import 'package:equatable/equatable.dart';

class AppVersionEntity extends Equatable {
  final int paymentStatus;
  final int productStatus;
  final String paymentMessage;
  final String productMessage;
  final String apiBaseUrl;
  final String version;
  final String appLink;
  final String deploymentStatus;
  final String? userDetailsFlag;
  final String searchRadius;
  final List<DistanceRadiusEntity> distanceRadiusFilters;
  final String isForcePaymentPage;
  final int status;

  const AppVersionEntity({
    required this.paymentStatus,
    required this.productStatus,
    required this.paymentMessage,
    required this.productMessage,
    required this.apiBaseUrl,
    required this.version,
    required this.appLink,
    required this.deploymentStatus,
    this.userDetailsFlag,
    required this.searchRadius,
    required this.distanceRadiusFilters,
    required this.isForcePaymentPage,
    required this.status,
  });

  @override
  List<Object?> get props => [
        paymentStatus,
        productStatus,
        paymentMessage,
        productMessage,
        apiBaseUrl,
        version,
        appLink,
        deploymentStatus,
        userDetailsFlag,
        searchRadius,
        distanceRadiusFilters,
        isForcePaymentPage,
        status,
      ];
}

class DistanceRadiusEntity extends Equatable {
  final int radius;

  const DistanceRadiusEntity({required this.radius});

  @override
  List<Object?> get props => [radius];
}
