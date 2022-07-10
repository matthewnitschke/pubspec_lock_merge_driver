
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

PubspecLock mergePubspecLocks(PubspecLock a, PubspecLock b) {
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
    return Version.prioritize(a.version, b.version) > 0 ? a : b;
  }
  if (a.description is T && b.description is! T) return a;
  if (b.description is T && a.description is! T) return b;

  return null;
}