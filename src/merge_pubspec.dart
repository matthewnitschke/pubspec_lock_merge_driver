import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'utils.dart';

Pubspec mergePubspec(Pubspec a, Pubspec b) {
  _validatePubspecBaseMergeability(a, b);

  // Dependencies, Dev Dependencies, Dependency Overrides

  // Environment?, executables? flutter? screenshots?

  return Pubspec(
    a.name,
    version: _mergeVersion(a.version, b.version),
    publishTo: a.publishTo,
    environment: _mergeEnvironment(a.environment, b.environment),
    homepage: a.homepage,
    repository: a.repository,
    issueTracker: a.issueTracker,
    screenshots: [],
    documentation: a.documentation,
    description: a.description,
    dependencies: {},
    devDependencies: {},
    dependencyOverrides: {},
    flutter: {}
  );
}

Version? _mergeVersion(Version? a, Version? b) {
  return nullableMerge<Version>(
    a, 
    b,
    onEqual: (a, b) => Version.prioritize(a, b) > 0 ? a : b
  );
}

Map<String, VersionConstraint?>? _mergeEnvironment(
  Map<String, VersionConstraint?>? a,
  Map<String, VersionConstraint?>? b,
) {
  return nullableMerge(
    a,
    b,
    onEqual: (a, b) => mergeMaps(
      a,
      b,
      onDuplicate:(a, b) => nullableMerge(a, b, onEqual: _mergeVersionConstraint),
    )
  );
}

void _validatePubspecBaseMergeability(Pubspec a, Pubspec b) {
  if (a.name != b.name) throw PubspecMergeException('names not equal');
  if (a.publishTo != b.publishTo) throw PubspecMergeException('publish tos trackers not equal');
  if (a.homepage.toString() != b.homepage.toString()) throw PubspecMergeException('homepages not equal');
  if (a.repository.toString() != b.repository.toString()) throw PubspecMergeException('repositories not equal');
  if (a.issueTracker != b.issueTracker) throw PubspecMergeException('issue trackers not equal');
  if (a.documentation != b.documentation) throw PubspecMergeException('documentations not equal');
  if (a.description != b.description) throw PubspecMergeException('descriptions not equal');
}

class PubspecMergeException implements Exception {
  final String reason;
  PubspecMergeException(this.reason);
}

VersionConstraint _mergeVersionConstraint(VersionConstraint a, VersionConstraint b) {
  if (a is! VersionRange || b is! VersionRange) throw PubspecMergeException('cannot merge non-version range dependencies');

  if (a.max.toString() != b.max.toString()) throw PubspecMergeException('cannot merge different max versions');

  if (a.min == null || b.min == null) throw PubspecMergeException('cannot merge empty min versions');

  final minVersion = Version.prioritize(a.min!, b.min!) > 0 ? a : b; 
  return VersionConstraint.parse('${minVersion.toString} ${a.max.toString()}'.trim());

}