import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../models/app_version_model.dart';

abstract class AppRemoteDataSource {
  Future<AppVersionModel> getAppVersion({
    required int roleId,
    required String device,
    required String versionNumber,
  });
}

class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  final ApiClient apiClient;

  AppRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AppVersionModel> getAppVersion({
    required int roleId,
    required String device,
    required String versionNumber,
  }) async {
    final response = await apiClient.post(
      ApiConstants.getAppVersion,
      queryParameters: {
        ApiConstants.roleId: roleId,
        ApiConstants.device: device,
        ApiConstants.versionNumber: versionNumber,
      },
    );

    if (response.data != null) {
      try {
        return AppVersionModel.fromJson(response.data);
      } catch (e) {
        throw ParsingException('Failed to parse app version response');
      }
    } else {
      throw ServerException(message: 'Empty response from server');
    }
  }
}
