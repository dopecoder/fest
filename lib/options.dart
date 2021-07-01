import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';

const CONFIG_FILE_NAME = 'fest.config';

const forceUpdateSnapshotsFlag = 'update-snapshots';
const forceUpdateSnapshotsAbbrFlag = 'u';
const driverPathOption = 'driver-path';
const driverPathAbbrOption = 'd';
const testsPathOption = 'tests-path';
const testsPathAbbrOption = 't';
const snapsPathOption = 'snaps-path';
const snapsPathAbbrOption = 'p';
const helpFlag = 'help';
const helpAbbrFlag = 'h';

class SnapshotTestOptions extends Equatable {
  final String snapshotDirPath;
  final String testsDirPath;
  final String driverDirPath;
  final bool forceCaptureMode;
  SnapshotTestOptions({
    required this.snapshotDirPath,
    required this.testsDirPath,
    required this.driverDirPath,
    required this.forceCaptureMode,
  });

  factory SnapshotTestOptions.defaultOptions(
      {String? projectPath,
      String? snapshotDirPath,
      String? testsDirPath,
      String? driverDirPath,
      bool? forceCaptureMode,
      bool? releaseMode}) {
    final projectDir = projectPath ?? Directory.current.path;
    return SnapshotTestOptions(
      snapshotDirPath: snapshotDirPath ?? '$projectDir/fest/snapshots',
      testsDirPath: testsDirPath ?? '$projectDir/integration_tests',
      driverDirPath:
          driverDirPath ?? '$projectDir/integration_tests/test_driver',
      forceCaptureMode: forceCaptureMode ?? false,
    );
  }

  Future<bool> save({String? path}) async {
    final file = File(path ?? CONFIG_FILE_NAME);
    try {
      await file.writeAsString(jsonEncode(toJson()));
      return true;
    } catch (e) {
      print(
          'SnapshotTestOptions: (save) failed to save config file $CONFIG_FILE_NAME - $e');
    }
    return false;
  }

  static Future<SnapshotTestOptions?> load({String? path}) async {
    final file = File(path ?? CONFIG_FILE_NAME);
    try {
      final content = await file.readAsString();
      final json = jsonDecode(content);
      return fromJson(json);
    } catch (e) {
      print(
          'SnapshotTestOptions: (load) failed to load config file $CONFIG_FILE_NAME - $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      forceUpdateSnapshotsFlag: forceCaptureMode,
      driverPathOption: driverDirPath,
      testsPathOption: testsDirPath,
      snapsPathOption: snapshotDirPath,
    };
  }

  static SnapshotTestOptions fromJson(dynamic json) {
    final driverPathString = json[driverPathOption];
    final testsPathString = json[testsPathOption];
    final snapsPathString = json[snapsPathOption];
    final forceUpdateSnapshot = json[forceUpdateSnapshotsFlag];
    return SnapshotTestOptions(
      driverDirPath: driverPathString,
      testsDirPath: testsPathString,
      snapshotDirPath: snapsPathString,
      forceCaptureMode: forceUpdateSnapshot,
    );
  }

  @override
  List<Object?> get props => [
        snapshotDirPath,
        testsDirPath,
        driverDirPath,
        forceCaptureMode,
      ];
}
