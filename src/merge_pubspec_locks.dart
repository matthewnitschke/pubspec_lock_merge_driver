import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

PubspecLock mergePubspecLocks(PubspecLock a, PubspecLock b) {
  a.sdks.forEach((name, versionConstraint) {
    if (!b.sdks.containsKey(name)) {
      throw PubspecLockMergeException('lockfile sdks are not equal');
    }

    if (versionConstraint.toString() != b.sdks[name].toString()) {
      throw PubspecLockMergeException('lockfile sdks are not equal');
    }
  });

  final duplicateKeys = a.packages.keys.toSet().intersection(b.packages.keys.toSet());
  final mergedPackages = <String, Package>{...a.packages, ...b.packages}.map((packageName, package) {
    if (duplicateKeys.contains(packageName)) {
      final aPackage = a.packages[packageName]!;
      final bPackage = b.packages[packageName]!;

      final aPackageDesc = aPackage.description;
      final bPackageDesc = bPackage.description;

      if (aPackageDesc.runtimeType != bPackageDesc.runtimeType) {
        throw PubspecLockMergeException('package descriptions are different types');
      }

      if (!_arePackageDescriptionsEqual(aPackageDesc, bPackageDesc)) {
        throw PubspecLockMergeException('package descriptions are same type, but have different values');
      }

      final priorityPackage = Version.prioritize(aPackage.version, bPackage.version) > 0 ? aPackage : bPackage;

      return MapEntry(packageName, priorityPackage);
    }

    return MapEntry(packageName, package);
  });

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
