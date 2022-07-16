import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';
import 'package:test/test.dart';

import '../src/merge_pubspec_locks.dart';

Package _buildTestPackage(
    {String dependency = 'transitive',
    PackageDescription? packageDescription,
    PackageSource source = PackageSource.hosted,
    String version = '1.0.0'}) {
  return Package(
      dependency: dependency,
      description: packageDescription ??
          HostedPackageDescription(
            name: 'test_name',
            url: 'test_url',
          ),
      source: source,
      version: Version.parse(version));
}

final _testPathDesc = PathPackageDescription(path: './path', relative: true);
final _testGitDesc = GitPackageDescription(
  path: './',
  ref: 'root',
  resolvedRef: 'abcd',
  url: 'http',
);
final _testHostedDesc = HostedPackageDescription(name: 'test', url: 'someUrl');

void main() {
  group('mergePubspecLocks', () {
    test('merges non-duplicated packages', () {
      final actual = mergePubspecLocks(
        PubspecLock(sdks: {}, packages: {'depA': _buildTestPackage()}),
        PubspecLock(sdks: {}, packages: {'depB': _buildTestPackage()}),
      ).packages;

      expect(actual.keys, {'depA', 'depB'});
    });

    test('chooses latest path version', () {
      final actual = mergePubspecLocks(
        PubspecLock(sdks: {}, packages: {
          'depA': _buildTestPackage(
            packageDescription: _testPathDesc,
            version: '1.2.1',
          )
        }),
        PubspecLock(sdks: {}, packages: {
          'depA': _buildTestPackage(
            packageDescription: _testPathDesc,
            version: '2.9.0',
          )
        }),
      ).packages;

      expect(actual.length, 1);
      expect(actual.values.first.version.toString(), '2.9.0');
    });

    test('chooses latest git version', () {
      final actual = mergePubspecLocks(
        PubspecLock(sdks: {}, packages: {
          'depA': _buildTestPackage(packageDescription: _testGitDesc, version: '2.9.0'),
        }),
        PubspecLock(sdks: {}, packages: {
          'depA': _buildTestPackage(packageDescription: _testGitDesc, version: '1.2.1'),
        }),
      ).packages;

      expect(actual.length, 1);
      expect(actual.values.first.version.toString(), '2.9.0');
    });

    test('chooses latest hosted version', () {
      final actual = mergePubspecLocks(
        PubspecLock(sdks: {}, packages: {
          'depA': _buildTestPackage(
            packageDescription: _testHostedDesc,
            version: '2.9.0',
          )
        }),
        PubspecLock(sdks: {}, packages: {
          'depA': _buildTestPackage(
            packageDescription: _testHostedDesc,
            version: '1.2.1',
          )
        }),
      ).packages;

      expect(actual.length, 1);
      expect(actual.values.first.version.toString(), '2.9.0');
    });

    test('fails on different package description types', () {
      expect(
        () => mergePubspecLocks(
          PubspecLock(sdks: {}, packages: {
            'depA': _buildTestPackage(packageDescription: _testGitDesc, version: '2.9.0'),
          }),
          PubspecLock(sdks: {}, packages: {
            'depA': _buildTestPackage(packageDescription: _testHostedDesc, version: '1.2.1'),
          }),
        ),
        throwsException,
      );
    });

    test('fails on sdk differences', () {
      expect(
        () => mergePubspecLocks(
          PubspecLock(sdks: {
            'environment': VersionConstraint.parse('>=1.0.0 <2.0.0'),
          }, packages: {}),
          PubspecLock(sdks: {
            'environment': VersionConstraint.parse('>=1.2.0 <2.0.0'),
          }, packages: {}),
        ),
        throwsException,
      );
    });

    test('fails on description differences', () {
      expect(
        () => mergePubspecLocks(
          PubspecLock(sdks: {}, packages: {
            'depA': _buildTestPackage(
              packageDescription: PathPackageDescription(path: 'somewhere', relative: false),
            )
          }),
          PubspecLock(sdks: {}, packages: {
            'depA': _buildTestPackage(
              packageDescription: PathPackageDescription(path: 'somewhere/different', relative: false),
            )
          }),
        ),
        throwsException,
      );
    });
  });
}
