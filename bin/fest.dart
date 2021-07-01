import 'dart:io';

import 'package:args/args.dart';
import 'package:fest/options.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addFlag(forceUpdateSnapshotsFlag,
      abbr: forceUpdateSnapshotsAbbrFlag, defaultsTo: false);
  parser.addOption(driverPathOption,
      abbr: driverPathAbbrOption, defaultsTo: 'integration-tests/app.dart');
  parser.addOption(testsPathOption,
      abbr: testsPathAbbrOption, defaultsTo: 'integration-tests/');
  parser.addOption(snapsPathOption,
      abbr: snapsPathAbbrOption, defaultsTo: 'integration-tests/snaps/');
  parser.addFlag(helpFlag, abbr: helpAbbrFlag, defaultsTo: false);
  final results = parser.parse(arguments);
  if (results[helpFlag]) {
    print('Flutter Snapshot Testing Tool');
    print(
        ' --$driverPathOption (-$driverPathAbbrOption)\t\tSupply the absolute or relative path of the app driver (default: integration-tests/app.dart)');
    print(
        ' --$testsPathOption (-$testsPathAbbrOption)\t\tSupply the absolute or relative path of the folder containing tests (default: integration-tests/)');
    print(
        ' --$snapsPathOption (-$snapsPathAbbrOption)\t\tSupply the absolute or relative path of the folder to store snapshots (default: integration-tests/snaps/)');
    print(
        ' --$forceUpdateSnapshotsFlag (-$forceUpdateSnapshotsAbbrFlag)\tUpdate all snapshots (all tests passes and the new snapshots are saved)');
    print(' --$helpFlag (-$helpAbbrFlag)\t\t\tHelp');
    return;
  }

  final opts = SnapshotTestOptions.fromJson(results);
  await opts.save(path: CONFIG_FILE_NAME);

  print('Test Options:-');
  print(' * Driver Path - ${opts.driverDirPath}');
  print(' * Tests Path - ${opts.testsDirPath}');
  print(' * Snapshots Path - ${opts.snapshotDirPath}');
  print(' * Force update all snapshots? - ${opts.forceCaptureMode}');
  // todo : check if the paths are valid

  // start tests
  final process = await Process.start('flutter', [
    'drive',
    '--target=${opts.driverDirPath}',
  ]);
  process.stdout.listen((List<int> event) {
    stdout.add(event);
  }, onDone: () async => print('Completed!'));
  process.stderr.listen((event) {
    stderr.add(event);
  });
}
