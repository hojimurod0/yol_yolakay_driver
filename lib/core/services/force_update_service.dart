import '../config/app_config.dart';

enum UpdateRequirement {
  none,
  optional,
  required,
}

class ForceUpdatePolicy {
  const ForceUpdatePolicy({
    required this.minimumSupportedVersion,
    required this.latestVersion,
    required this.forceUpdate,
    this.releaseNotes,
  });

  final String minimumSupportedVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String? releaseNotes;
}

class ForceUpdateService {
  /// Compares semantic versions (e.g. 1.0.0 vs 1.1.0).
  /// Returns:
  /// - Negative if v1 < v2
  /// - Zero if v1 == v2
  /// - Positive if v1 > v2
  static int compareSemanticVersion(String v1, String v2) {
    final v1Parts = _parseVersion(v1);
    final v2Parts = _parseVersion(v2);

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }
    return 0;
  }

  static List<int> _parseVersion(String v) {
    final clean = v.split('+').first.split('-').first.trim();
    final parts = clean.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts.sublist(0, 3);
  }

  UpdateRequirement checkUpdateRequirement(
    ForceUpdatePolicy policy, {
    String currentVersion = AppConfig.appVersion,
  }) {
    // If current < minimumSupportedVersion -> required update
    if (compareSemanticVersion(currentVersion, policy.minimumSupportedVersion) <
        0) {
      return UpdateRequirement.required;
    }

    // If forceUpdate flag is true and current < latestVersion -> required update
    if (policy.forceUpdate &&
        compareSemanticVersion(currentVersion, policy.latestVersion) < 0) {
      return UpdateRequirement.required;
    }

    // If current < latestVersion -> optional update
    if (compareSemanticVersion(currentVersion, policy.latestVersion) < 0) {
      return UpdateRequirement.optional;
    }

    return UpdateRequirement.none;
  }
}
