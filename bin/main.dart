import 'dart:io';
import 'package:json2yaml/json2yaml.dart';
import 'package:pubspec_lock_parse/pubspec_lock_parse.dart';

import '../src/merge_pubspec_locks.dart';

void main(List<String> args) {
  if (args.length != 2) {
    stderr.writeln('error: exactly 2 pubspec.lock contents are required to run merge driver');
    exit(1);
  }

  final pubspecContentA = args.first;
  final pubspecContentB = args.last;

  PubspecLock pubspecLockA;
  PubspecLock pubspecLockB;
  try {
    pubspecLockA = PubspecLock.parse(pubspecContentA);
    pubspecLockB = PubspecLock.parse(pubspecContentB);
  } catch (_) {
    stderr.writeln('error: unable to parse provided pubspec files');
    exit(1);
  }

  PubspecLock mergedLockfile;
  try {
    mergedLockfile = mergePubspecLocks(pubspecLockA, pubspecLockB);
  } on PubspecLockMergeException catch (e) {
    stderr.writeln('error: unable to merge lockfiles: ${e.reason}');
    exit(1);
  } catch(e) {
    stderr.writeln('error: unable to merge lockfiles: ${e.toString()}');
    exit(1);
  }


  stdout.write(
    '# Generated by pub\n'
    '# See https://dart.dev/tools/pub/glossary#lockfile\n'
  );

  stdout.write(json2yaml(
    mergedLockfile.toJson(),
    yamlStyle: YamlStyle.pubspecLock,
  ));
}
