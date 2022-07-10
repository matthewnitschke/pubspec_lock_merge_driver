
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

PubspecLock mergePubspecLocks(PubspecLock a, PubspecLock b) {
  a.sdks.forEach((name, versionConstraint) {
    if (!b.sdks.containsKey(name)) {
      throw PubspecLockMergeException('Pubspec lock sdks not equal');
    }

    if (versionConstraint.toString() != b.sdks[name].toString()) {
      throw PubspecLockMergeException('Pubspec lock sdks not equal');
    }
  });

  final duplicateKeys = a.packages.keys.toSet().intersection(b.packages.keys.toSet());
  final mergedPackages = <String, Package>{
    ...a.packages,
    ...b.packages
  }.map((packageName, package) {
    if (duplicateKeys.contains(packageName)) {
      final aPackage = a.packages[packageName]!;
      final bPackage = b.packages[packageName]!;


      final mergedPackage = _choosePriorityPackage<PathPackageDescription>(aPackage, bPackage) 
        ?? _choosePriorityPackage<GitPackageDescription>(aPackage, bPackage)
        ?? _choosePriorityPackage<HostedPackageDescription>(aPackage, bPackage)!;

      return MapEntry(packageName, mergedPackage);
    }

    return MapEntry(packageName, package);
  });

  return PubspecLock(sdks: a.sdks, packages: mergedPackages);
}

Package? _choosePriorityPackage<T extends PackageDescription>(Package a, Package b) {
  if (a.description is T && b.description is T) {
    if (!_arePackageDescriptionsEqual(a.description, b.description)) {
      throw PubspecLockMergeException('Package descriptions are same type, but have different values');
    }

    return Version.prioritize(a.version, b.version) > 0 ? a : b;
  }
  if (a.description is T && b.description is! T) return a;
  if (b.description is T && a.description is! T) return b;

  return null;
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