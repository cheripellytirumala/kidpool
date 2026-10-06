import '../../domain/entities/app_version_entity.dart';

class AppVersionModel {
  final int? paymentStatus;
  final int? productStatus;
  final String? paymentMessage;
  final String? productMessage;
  final String? apiBaseUrl;
  final String? version;
  final String? appLink;
  final String? deploymentStatus;
  final String? userDetailsFlag;
  final String? searchRadius;
  final List<DistanceRadiusModel>? distanceRadiusFilters;
  final String? isForcePaymentPage;
  final int? status;

  AppVersionModel({
    this.paymentStatus,
    this.productStatus,
    this.paymentMessage,
    this.productMessage,
    this.apiBaseUrl,
    this.version,
    this.appLink,
    this.deploymentStatus,
    this.userDetailsFlag,
    this.searchRadius,
    this.distanceRadiusFilters,
    this.isForcePaymentPage,
    this.status,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      paymentStatus: json['payment_status'],
      productStatus: json['product_status'],
      paymentMessage: json['payment_message'],
      productMessage: json['product_message'],
      apiBaseUrl: json['api_base_url'],
      version: json['version'],
      appLink: json['App_Link'],
      deploymentStatus: json['deployment_status']?.toString(),
      userDetailsFlag: json['user_details_flag'],
      searchRadius: json['search_radius']?.toString(),
      distanceRadiusFilters: (json['distance_radius_filters'] as List?)
          ?.map((i) => DistanceRadiusModel.fromJson(i))
          .toList(),
      isForcePaymentPage: json['is_force_payment_page']?.toString(),
      status: json['status'],
    );
  }

  AppVersionEntity toEntity() {
    return AppVersionEntity(
      paymentStatus: paymentStatus ?? 0,
      productStatus: productStatus ?? 0,
      paymentMessage: paymentMessage ?? '',
      productMessage: productMessage ?? '',
      apiBaseUrl: apiBaseUrl ?? '',
      version: version ?? '',
      appLink: appLink ?? '',
      deploymentStatus: deploymentStatus ?? '0',
      userDetailsFlag: userDetailsFlag,
      searchRadius: searchRadius ?? '0',
      distanceRadiusFilters: distanceRadiusFilters?.map((e) => e.toEntity()).toList() ?? [],
      isForcePaymentPage: isForcePaymentPage ?? '0',
      status: status ?? 0,
    );
  }
}

class DistanceRadiusModel {
  final int? radius;

  DistanceRadiusModel({this.radius});

  factory DistanceRadiusModel.fromJson(Map<String, dynamic> json) {
    return DistanceRadiusModel(
      radius: json['radius'] is int ? json['radius'] : int.tryParse(json['radius']?.toString() ?? ''),
    );
  }

  DistanceRadiusEntity toEntity() {
    return DistanceRadiusEntity(radius: radius ?? 0);
  }
}
