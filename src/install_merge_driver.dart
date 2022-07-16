import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

/// Thanks to https://github.com/npm/npm-merge-driver, for much of this implementation

class InstallCommand extends Command {
  @override
  final name = 'install';

  @override
  final description = 'installs the merge driver';

  InstallCommand() {
    argParser
      ..addFlag('local', defaultsTo: false)
      ..addOption('driverName', defaultsTo: 'pubspec_merge_driver');
  }

  Future<void> run() async {
    final isGlobal = !(argResults!['local'] as bool);
    final driverName = argResults!['driverName'] as String;

    final opts = isGlobal ? '--global' : '--local';

    await Process.run('git', ['config', opts, 'merge.$driverName.name', 'automatically merge pub lockfiles']);
    await Process.run('git', ['config', opts, 'merge.$driverName.driver', 'pubspec_lock_merge_driver merge \$(cat %A) \$(cat %B) > %A']);

    final attrFilePath = (await _findAttributesFilePath(isGlobal: isGlobal)).replaceFirst(
      RegExp(r'/^\s*~\//'), 
      Platform.environment['HOME']!,
    );
    await Process.run('mkdir', ['-p', p.dirname(attrFilePath)]); 

    String attrContents = '';
    try {
      final re = RegExp('.* merge\\s*=\\s*${driverName}\$');
      attrContents = File(attrFilePath)
        .readAsStringSync()
        .split(RegExp(r'\r?\n'))
        .where((line) => re.hasMatch(line))
        .join('\n');
    } catch(e) {}

    if (attrContents.isNotEmpty && !RegExp(r'[\n\r]$', multiLine: true).hasMatch(attrContents)) {
      attrContents = '\n';
    }

    attrContents += 'pubspec.lock merge=${driverName}\n';

    File(attrFilePath).writeAsStringSync(attrContents);

    print('pubspec_lock_merge_driver: $driverName installed to \'git config ${opts}\' and $attrFilePath');
  }
}

class UninstallCommand extends Command {
  @override
  final name = 'uninstall';

  @override
  final description = 'uninstalls the merge driver';

  UninstallCommand() {
    argParser
      ..addFlag('local', defaultsTo: false)
      ..addOption('driverName', defaultsTo: 'pubspec_merge_driver');
  }

  Future<void> run() async {
    final isGlobal = !(argResults!['local'] as bool);
    final driverName = argResults!['driverName'] as String;

    final opts = isGlobal ? '--global' : '--local';

    await Process.run('git', ['config', opts, '--remove-section', 'merge.$driverName']);

    final attrFilePath = await _findAttributesFilePath(isGlobal: isGlobal);
    final attrContent = File(attrFilePath).readAsLinesSync();

    if (attrContent.isNotEmpty) {
      final newAttrContent = attrContent
        .where((line) {
          final match = RegExp(' merge=(.*)\$', caseSensitive: false).firstMatch(line);
          return match?.group(1)?.trim() != driverName;
        })
        .join('\n');
      
      File(attrFilePath).writeAsString(newAttrContent);
    }
  }
}

Future<String> _findAttributesFilePath({bool isGlobal = false}) async {
  if (isGlobal) {
    final globalConfigProc = await Process.run('git', ['config' '--global' 'core.attributesfile']);
    final globalConfig = (globalConfigProc.stdout as String?)?.trim();
    if (globalConfig?.isNotEmpty == true) return globalConfig!;

    if (Platform.environment.containsKey('XDG_CONFIG_HOME')) {
      return p.join(Platform.environment['XDG_CONFIG_HOME']!, 'git', 'attributes');
    } else {
      return p.join(Platform.environment['HOME']!, '.config', 'git', 'attributes');
    }
  } else {
    final gitDirProc = await Process.run('git', ['rev-parse', '--git-dir']);
    final gitDir = (gitDirProc.stdout as String).trim();
    return p.join(gitDir, 'info', 'attributes');
  }
}