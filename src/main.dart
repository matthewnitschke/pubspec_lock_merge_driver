import 'dart:io';
import 'package:json2yaml/json2yaml.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

import 'merge_pubspec_locks.dart';

void main(List<String> args) {
  if (args.length != 2) stderr.writeln('error: exactly 2 pubspec.lock contents are required to run merge driver');;

  final pubspecContentA = args.first;
  final pubspecContentB = args.last;

  final pubspecLockA = PubspecLock.parse(pubspecContentA);
  final pubspecLockB = PubspecLock.parse(pubspecContentB);

  final newLock = mergePubspecLocks(pubspecLockA, pubspecLockB);

  stdout.write(
    '# Generated by pub\n'
    '# See https://dart.dev/tools/pub/glossary#lockfile\n'
  );

  stdout.write(json2yaml(
    newLock.toJson(),
    yamlStyle: YamlStyle.pubspecLock,
  ));
}
