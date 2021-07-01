import 'dart:io';

import 'package:fest/options.dart';
import 'package:test/test.dart';

void main() {
  group('SnapshotTestOptions', () {
    setUpAll(() async {});

    tearDownAll(() async {
      var f = File('./fest.config');
      if (f.existsSync()) {
        f.deleteSync();
      }
    });

    test('load, returns nil if config file doesn\'t exist', () async {
      var loadTestOptions =
          await SnapshotTestOptions.load(path: CONFIG_FILE_NAME);
      expect(loadTestOptions, null);
    });

    test('save, returns false if save fails', () async {
      var testOptions =
          SnapshotTestOptions.defaultOptions(snapshotDirPath: './test/snaps');

      final saved = await testOptions.save(path: '/////');
      expect(saved, false);
    });

    test('save, saves config to file', () async {
      var testOptions = SnapshotTestOptions.defaultOptions(
          projectPath: './', snapshotDirPath: './test/snaps');
      await testOptions.save(path: CONFIG_FILE_NAME);
      expect(File('./fest.config').existsSync(), true);
    });

    test('load, loads options from file', () async {
      var saveTestOptions = SnapshotTestOptions.defaultOptions(
          projectPath: './', snapshotDirPath: './test/snaps');
      await saveTestOptions.save(path: CONFIG_FILE_NAME);
      var loadTestOptions =
          await SnapshotTestOptions.load(path: CONFIG_FILE_NAME);
      expect(loadTestOptions, saveTestOptions);
      // expect(File('./fest.config').existsSync(), true);
    });

    test('toJson, converts to right json object', () async {
      var testOptions = SnapshotTestOptions.defaultOptions(
          snapshotDirPath: './test/snaps', projectPath: '.');
      var json = testOptions.toJson();
      expect(json, {
        forceUpdateSnapshotsFlag: false,
        driverPathOption: './integration_tests/test_driver',
        testsPathOption: './integration_tests',
        snapsPathOption: './test/snaps',
      });
    });

    test('fromJson, converts to right json to options object', () async {
      var json = {
        forceUpdateSnapshotsFlag: false,
        driverPathOption: './integration_tests/test_driver',
        testsPathOption: './integration_tests',
        snapsPathOption: './test/snaps',
      };
      var testOptionsFromJson = SnapshotTestOptions.fromJson(json);
      var testOptions = SnapshotTestOptions.defaultOptions(
          snapshotDirPath: './test/snaps', projectPath: '.');
      expect(testOptionsFromJson, testOptions);
    });
  });
}
