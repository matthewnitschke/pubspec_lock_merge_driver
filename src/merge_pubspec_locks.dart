import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

import 'utils.dart';

PubspecLock mergePubspecLocks(PubspecLock a, PubspecLock b) {
  a.sdks.forEach((name, versionConstraint) {
    if (!b.sdks.containsKey(name)) {
      throw PubspecLockMergeException('lockfile sdks are not equal');
    }

    if (versionConstraint.toString() != b.sdks[name].toString()) {
      throw PubspecLockMergeException('lockfile sdks are not equal');
    }
  });

  final mergedPackages = mergeMaps<String, Package>(
    a.packages,
    b.packages,
    onDuplicate: (aPackage, bPackage) {
      final aPackageDesc = aPackage.description;
      final bPackageDesc = bPackage.description;

      if (aPackageDesc.runtimeType != bPackageDesc.runtimeType) {
        throw PubspecLockMergeException('package descriptions are different types');
      }

      if (!_arePackageDescriptionsEqual(aPackageDesc, bPackageDesc)) {
        throw PubspecLockMergeException('package descriptions are same type, but have different values');
      }

      return Version.prioritize(aPackage.version, bPackage.version) > 0 ? aPackage : bPackage;
    }
  );

  return PubspecLock(sdks: a.sdks, packages: mergedPackages);
}

bool _arePackageDescriptionsEqual(PackageDescription a, PackageDescription b) {
  if (a is PathPackageDescription && b is PathPackageDescription) {
    return a.path == b.path && a.relative == b.relative;
  } else if (a is GitPackageDescription && b is GitPackageDescription) {
    return a.path == b.path && a.ref == b.ref && a.resolvedRef == b.resolvedRef && a.url == b.url;
  } else if (a is HostedPackageDescription && b is HostedPackageDescription) {
    return a.name == b.name && a.url == b.url;
  }

  return false;
}

class PubspecLockMergeException implements Exception {
  final String reason;
  PubspecLockMergeException(this.reason);
}
