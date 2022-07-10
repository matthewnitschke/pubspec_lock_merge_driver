import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';
import 'package:test/test.dart';

import '../src/merge_pubspec_locks.dart';

Package _buildTestPackage({
  String dependency = 'transitive',
  PackageDescription? packageDescription,
  PackageSource source = PackageSource.hosted,
  String version = '1.0.0'
}) {
  return Package(
    dependency: dependency,
    description: packageDescription ?? HostedPackageDescription(
      name: 'test_name',
      url: 'test_url'
    ),
    source: source,
    version: Version.parse(version)
  );
}

void main() {
  group('mergePubspecLocks', () {
    test('merges non-duplicated packages', () {
      final actual = mergePubspecLocks(
        PubspecLock(sdks: {}, packages: {
          'depA': _buildTestPackage()
        }),
        PubspecLock(sdks: {}, packages: {
          'depB': _buildTestPackage()
        }),
      ).packages;

      expect(actual.keys, {'depA', 'depB'});      
    });

    test('chooses path package over hosted package', () {
      final actual =  mergePubspecLocks(
        PubspecLock(sdks: {}, packages: {
          'depA': _buildTestPackage(
            packageDescription: PathPackageDescription(path: './path', relative: true)
          )
        }),
        PubspecLock(sdks: {}, packages: {
          'depA': _buildTestPackage()
        }),
      ).packages;
    });
    
    test('chooses path package over git package', () {});

    test('chooses git package over hosted package', () {});

    test('chooses latest path version', () { });
    
    test('chooses latest git version', () { });

    test('chooses latest hosted version', () { });

    
  });
}