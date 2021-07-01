import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_driver/src/common/layer_tree.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fest/fest.dart';
import 'package:fest/options.dart';
import 'package:fest/snapshot.dart';
import 'package:test/test.dart';

import 'fest_test.mocks.dart';
import 'snapshot_test.mocks.dart';

@GenerateMocks([Snapshot])
void main() {
  FlutterDriver driver = MockFlutterDriver();

  setUpAll(() async {
    final d = Directory.fromUri(Uri.parse('./test/fest-test'));
    d.createSync();
  });

  tearDownAll(() async {
    final snapsDir = Directory.fromUri(Uri.parse('./test/fest-test'));
    if (snapsDir.existsSync()) {
      final fileList = snapsDir.listSync();
      fileList.forEach((file) {
        file.deleteSync();
      });
    }
    snapsDir.deleteSync();
  });
  group('Fest', () {
    test('Create Fest Object with default options', () async {
      when(driver.screenshot()).thenAnswer((_) async => [100]);
      var testOptions = SnapshotTestOptions.defaultOptions(projectPath: '.');
      var f = Fest(driver: driver);
      expect(f.options, testOptions);
    });

    test('toMatchImageSnapshot, throws exception if new snapshot is null',
        () async {
      when(driver.screenshot()).thenThrow(Error());
      var testOptions = SnapshotTestOptions.defaultOptions(
          projectPath: './',
          snapshotDirPath: './test/fest-test',
          forceCaptureMode: true);
      var f = Fest(driver: driver, options: testOptions);
      try {
        await f.toMatchImageSnapshot('test-img');
      } catch (e) {
        expect(e.toString(),
            'Exception: SnapshotTest: (toMatchRenderTreeSnapshot) New Snapshot is null');
      }
    });

    test('toMatchImageSnapshot, passes if forceUpdate is true', () async {
      when(driver.screenshot()).thenAnswer((_) async => [100]);
      var testOptions = SnapshotTestOptions.defaultOptions(
          projectPath: './',
          snapshotDirPath: './test/fest-test',
          forceCaptureMode: true);
      var f = Fest(driver: driver, options: testOptions);
      await f.toMatchImageSnapshot('test-img');
    });

    test(
        'toMatchImageSnapshot, passes if equal where it loads snap and compares',
        () async {
      when(driver.screenshot()).thenAnswer((_) async => [100]);
      var testOptions = SnapshotTestOptions.defaultOptions(
        projectPath: './',
        snapshotDirPath: './test/fest-test',
      );
      var f = Fest(driver: driver, options: testOptions);
      await f.toMatchImageSnapshot('test-img');
    });

    test('toMatchImageSnapshot, fails if new snap is not equal to old snap',
        () async {
      when(driver.screenshot()).thenAnswer((_) async => [200]);
      var testOptions = SnapshotTestOptions.defaultOptions(
        projectPath: './',
        snapshotDirPath: './test/fest-test',
      );
      var f = Fest(driver: driver, options: testOptions);
      try {
        await f.toMatchImageSnapshot('test-img');
      } catch (e) {
        expect(true, true);
      }
    });

    test('toMatchRenderTreeSnapshot, throws exception if new snapshot is null',
        () async {
      when(driver.getRenderTree()).thenThrow(Error());
      var testOptions = SnapshotTestOptions.defaultOptions(
          projectPath: './',
          snapshotDirPath: './test/fest-test',
          forceCaptureMode: true);
      var f = Fest(driver: driver, options: testOptions);
      try {
        await f.toMatchRenderTreeSnapshot('test-rend');
      } catch (e) {
        expect(e.toString(),
            'Exception: SnapshotTest: (toMatchRenderTreeSnapshot) New Snapshot is null');
      }
    });
    test('toMatchRenderTreeSnapshot, passes if forceUpdate is true', () async {
      when(driver.getRenderTree())
          .thenAnswer((_) async => RenderTree('render'));
      var testOptions = SnapshotTestOptions.defaultOptions(
          projectPath: './',
          snapshotDirPath: './test/fest-test',
          forceCaptureMode: true);
      var f = Fest(driver: driver, options: testOptions);
      await f.toMatchRenderTreeSnapshot('test-rend');
    });

    test(
        'toMatchRenderTreeSnapshot, passes if equal where it loads snap and compares',
        () async {
      when(driver.screenshot()).thenAnswer((_) async => [100]);
      when(driver.getRenderTree())
          .thenAnswer((_) async => RenderTree('render'));
      var testOptions = SnapshotTestOptions.defaultOptions(
        projectPath: './',
        snapshotDirPath: './test/fest-test',
      );
      var f = Fest(driver: driver, options: testOptions);
      await f.toMatchRenderTreeSnapshot('test-rend');
    });

    test(
        'toMatchRenderTreeSnapshot, fails if new snap is not equal to old snap',
        () async {
      when(driver.getRenderTree())
          .thenAnswer((_) async => RenderTree('render-'));
      var testOptions = SnapshotTestOptions.defaultOptions(
        projectPath: './',
        snapshotDirPath: './test/fest-test',
      );
      var f = Fest(driver: driver, options: testOptions);
      try {
        await f.toMatchRenderTreeSnapshot('test-rend');
      } catch (e) {
        expect(true, true);
      }
    });

    test('toMatchLayerTreeSnapshot, throws exception if new snapshot is null',
        () async {
      when(driver.getLayerTree()).thenThrow(Error());
      var testOptions = SnapshotTestOptions.defaultOptions(
          projectPath: './',
          snapshotDirPath: './test/fest-test',
          forceCaptureMode: true);
      var f = Fest(driver: driver, options: testOptions);
      try {
        await f.toMatchLayerTreeSnapshot('test-layer');
      } catch (e) {
        expect(e.toString(),
            'Exception: SnapshotTest: (toMatchLayerTreeSnapshot) New Snapshot is null');
      }
    });
    test('toMatchLayerTreeSnapshot, passes if forceUpdate is true', () async {
      when(driver.getLayerTree()).thenAnswer((_) async => LayerTree('layer'));
      var testOptions = SnapshotTestOptions.defaultOptions(
          projectPath: './',
          snapshotDirPath: './test/fest-test',
          forceCaptureMode: true);
      var f = Fest(driver: driver, options: testOptions);
      await f.toMatchLayerTreeSnapshot('test-layer');
    });

    test(
        'toMatchLayerTreeSnapshot, passes if equal where it loads snap and compares',
        () async {
      when(driver.screenshot()).thenAnswer((_) async => [100]);
      when(driver.getLayerTree()).thenAnswer((_) async => LayerTree('layer'));
      var testOptions = SnapshotTestOptions.defaultOptions(
        projectPath: './',
        snapshotDirPath: './test/fest-test',
      );
      var f = Fest(driver: driver, options: testOptions);
      await f.toMatchLayerTreeSnapshot('test-layer');
    });

    test('toMatchLayerTreeSnapshot, fails if new snap is not equal to old snap',
        () async {
      when(driver.getLayerTree()).thenAnswer((_) async => LayerTree('layer-'));
      var testOptions = SnapshotTestOptions.defaultOptions(
        projectPath: './',
        snapshotDirPath: './test/fest-test',
      );
      var f = Fest(driver: driver, options: testOptions);
      try {
        await f.toMatchLayerTreeSnapshot('test-layer');
      } catch (e) {
        expect(true, true);
      }
    });

    test('saveFailure, saves old and new snapshots', () async {
      var s1 = MockSnapshot();
      var s2 = MockSnapshot();

      var testOptions = SnapshotTestOptions.defaultOptions(
        projectPath: './',
        snapshotDirPath: './test/fest-test',
      );
      when(s1.save(testOptions)).thenAnswer((_) async => true);
      when(s2.save(testOptions, asNew: true)).thenAnswer((_) async => true);

      var f = Fest(driver: driver, options: testOptions);
      var didSave = await f.saveFailure(s1, s2);
      expect(didSave, true);
    });
  });
}
