import 'dart:async';
import '../network/api_client.dart';
import '../utils/app_logger.dart';

abstract class FeatureFlagService {
  Future<void> initialize();
  bool isEnabled(String flagKey, {bool defaultValue = false});

  bool get taxiRadarEnabled;
  bool get intercityEnabled;
  bool get walletTopupEnabled;
  bool get paymeEnabled;
  bool get clickEnabled;
  bool get uzumEnabled;
  bool get reviewsEnabled;
  bool get supportChatEnabled;
  bool get newRadarAlgorithmEnabled;
}

class FeatureFlagServiceImpl implements FeatureFlagService {
  FeatureFlagServiceImpl({ApiClient? apiClient}) : _apiClient = apiClient;

  // ignore: unused_field
  final ApiClient? _apiClient;
  final Map<String, bool> _flags = {
    'taxiRadarEnabled': true,
    'intercityEnabled': true,
    'walletTopupEnabled': true,
    'paymeEnabled': true,
    'clickEnabled': true,
    'uzumEnabled': true,
    'reviewsEnabled': true,
    'supportChatEnabled': true,
    'newRadarAlgorithmEnabled': true,
  };

  @override
  Future<void> initialize() async {
    try {
      // Safe defaults are active. Remote config sync can be plugged in here.
    } catch (e) {
      AppLogger.warning('FeatureFlag fetch failed, using safe defaults: $e',
          module: LogModule.api);
    }
  }

  @override
  bool isEnabled(String flagKey, {bool defaultValue = false}) {
    return _flags[flagKey] ?? defaultValue;
  }

  @override
  bool get taxiRadarEnabled =>
      isEnabled('taxiRadarEnabled', defaultValue: true);
  @override
  bool get intercityEnabled =>
      isEnabled('intercityEnabled', defaultValue: true);
  @override
  bool get walletTopupEnabled =>
      isEnabled('walletTopupEnabled', defaultValue: true);
  @override
  bool get paymeEnabled => isEnabled('paymeEnabled', defaultValue: true);
  @override
  bool get clickEnabled => isEnabled('clickEnabled', defaultValue: true);
  @override
  bool get uzumEnabled => isEnabled('uzumEnabled', defaultValue: true);
  @override
  bool get reviewsEnabled => isEnabled('reviewsEnabled', defaultValue: true);
  @override
  bool get supportChatEnabled =>
      isEnabled('supportChatEnabled', defaultValue: true);
  @override
  bool get newRadarAlgorithmEnabled =>
      isEnabled('newRadarAlgorithmEnabled', defaultValue: true);
}
