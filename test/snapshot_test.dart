import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_driver/src/common/layer_tree.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fest/options.dart';
import 'package:fest/snapshot.dart';
import 'package:test/test.dart';

import 'snapshot_test.mocks.dart';

@GenerateMocks([FlutterDriver])
void main() {
  SnapshotTestOptions? testOptions;
  FlutterDriver driver = MockFlutterDriver();

  setUpAll(() async {
    final d = Directory.fromUri(Uri.parse('./test/snapshot-test'));
    d.createSync();
    testOptions = SnapshotTestOptions.defaultOptions(
        projectPath: './', snapshotDirPath: './test/snapshot-test');
  });

  tearDownAll(() async {
    final snapsDir = Directory.fromUri(Uri.parse('./test/snapshot-test'));
    if (snapsDir.existsSync()) {
      final fileList = snapsDir.listSync();
      fileList.forEach((file) {
        file.deleteSync();
      });
    }
    snapsDir.deleteSync();
  });
  group('Snapshot', () {
    test('Creating snapshot with no data throws exception', () async {
      try {
        Snapshot('test-1');
        expect(true, false);
      } catch (e) {
        expect(e.toString(),
            'Exception: Snapshot: Incorrect construction of Snapshot');
      }
    });

    test('saves image', () async {
      var s = Snapshot('test-1', image: [100]);
      await s.save(testOptions!);
      expect(File('./test/snapshot-test/test-1.image').existsSync(), true);
    });

    test('saves render tree', () async {
      var s = Snapshot('test-2', render: 'render');
      await s.save(testOptions!);
      expect(File('./test/snapshot-test/test-2.render').existsSync(), true);
    });

    test('saves layer tree', () async {
      var s = Snapshot('test-3', layer: 'layer');
      await s.save(testOptions!);
      expect(File('./test/snapshot-test/test-3.layer').existsSync(), true);
    });

    test('save, returns false if fails', () async {
      var s = Snapshot('test-save', image: [100]);
      final testOptions = SnapshotTestOptions.defaultOptions(
          projectPath: '////', snapshotDirPath: '////');
      final saved = await s.save(testOptions);
      expect(saved, false);
    });

    test('saveImage, saves the image int array as png', () async {
      var s = Snapshot('test-4', image: [100]);
      await s.saveImage(testOptions!, s.image!);
      expect(File('./test/snapshot-test/test-4.png').existsSync(), true);
    });

    test('saveImage, returns false if fails', () async {
      var s = Snapshot('test-5', image: [100]);
      final testOptions = SnapshotTestOptions.defaultOptions(
          projectPath: '////', snapshotDirPath: '////');
      final saved = await s.saveImage(testOptions, s.image!);
      expect(saved, false);
    });

    test('getSnapshotFromDriver, returns image snapshot', () async {
      when(driver.screenshot()).thenAnswer((_) async => [100]);
      expect(
          (await Snapshot.getSnapshotFromDriver(
                  'getImgFromDriver', SnapshotType.image, driver, []))
              ?.image,
          Snapshot('test-1', image: [100]).image);
    });

    test('getSnapshotFromDriver, returns render tree snapshot', () async {
      when(driver.getRenderTree())
          .thenAnswer((_) async => RenderTree('render'));
      expect(
          (await Snapshot.getSnapshotFromDriver(
                  'getRenderTreeFromDriver', SnapshotType.render, driver, []))
              ?.render,
          Snapshot('test-1', render: 'render').render);
    });

    test('getSnapshotFromDriver, returns layer tree snapshot', () async {
      when(driver.getLayerTree()).thenAnswer((_) async => LayerTree('layer'));
      expect(
          (await Snapshot.getSnapshotFromDriver(
                  'getLayerTreeFromDriver', SnapshotType.layer, driver, []))
              ?.layer,
          Snapshot('test-1', layer: 'layer').layer);
    });

    test('getSnapshotFromFile, returns image snapshot', () async {
      expect(
          (await Snapshot.getSnapshotFromFile(
                  'test-1', SnapshotType.image, testOptions!))
              ?.image,
          Snapshot('test-1', image: [100]).image);
    });

    test('getSnapshotFromFile, returns render tree snapshot', () async {
      expect(
          (await Snapshot.getSnapshotFromFile(
                  'test-2', SnapshotType.render, testOptions!))
              ?.render,
          Snapshot('test-2', render: 'render').render);
    });

    test('getSnapshotFromFile, returns layer tree snapshot', () async {
      expect(
          (await Snapshot.getSnapshotFromFile(
                  'test-3', SnapshotType.layer, testOptions!))
              ?.layer,
          Snapshot('test-3', layer: 'layer').layer);
    });

    test('getSnapshotData, returns image', () async {
      var s = Snapshot('test-5', image: [100]);
      expect(await s.getSnapshotData(), [100]);
    });

    test('getSnapshotData, returns render tree', () async {
      var s = Snapshot('test-7', render: 'Some\nRender\nTree');
      expect(await s.getSnapshotData(), 'Some\nRender\nTree');
    });

    test('getSnapshotData, returns layer tree', () async {
      var s = Snapshot('test-9', layer: 'Some\Layer\nTree');
      expect(await s.getSnapshotData(), 'Some\Layer\nTree');
    });

    test('matchesSnapshot, returns true if images are equal', () async {
      var s = Snapshot('test-5', image: [100]);
      s.matchesSnapshot(Snapshot('test-6', image: [100]));
    });

    test('matchesSnapshot, returns true if render trees are equal', () async {
      var s = Snapshot('test-7', render: 'Some\nRender\nTree');
      s.matchesSnapshot(Snapshot('test-8', render: 'Some\nRender\nTree'));
    });

    test('matchesSnapshot, returns true if layer trees are equal', () async {
      var s = Snapshot('test-9', layer: 'Some\Layer\nTree');
      s.matchesSnapshot(Snapshot('test-10', layer: 'Some\Layer\nTree'));
    });

    test('matchesSnapshot, returns false if images are not equal', () async {
      var s = Snapshot('test-5', image: [100]);
      try {
        s.matchesSnapshot(Snapshot('test-6', image: [101]));
      } catch (e) {
        expect(true, true);
      }
    });

    test('matchesSnapshot, returns false if render trees are not equal',
        () async {
      var s = Snapshot('test-7', render: 'Some\nRender\nTree ');
      try {
        s.matchesSnapshot(Snapshot('test-8', render: 'Some\nRender\nTree'));
      } catch (e) {
        expect(true, true);
      }
    });

    test('matchesSnapshot, returns false if layer trees are not equal',
        () async {
      var s = Snapshot('test-9', layer: 'Some\Layer\nTrees');
      try {
        s.matchesSnapshot(Snapshot('test-10', layer: 'Some\Layer\nTree'));
      } catch (e) {
        expect(true, true);
      }
    });

    test(
        'matchesSnapshot, throws exception if we try to compare different types',
        () async {
      var s = Snapshot('test-9', layer: 'Some\Layer\nTree');
      try {
        s.matchesSnapshot(Snapshot('test-11', image: [100]));
      } catch (e) {
        expect(e.toString(),
            'Exception: Snapshot: Cannot compare snapshots of different types');
      }
    });

    test('getSnapshotFile, replaces last / if passed in path', () async {
      final testOptions = SnapshotTestOptions.defaultOptions(
          projectPath: './', snapshotDirPath: './test/snapshot-test/');
      final f = await Snapshot.getSnapshotFile('test-1.image', testOptions);
      expect(f.path, './test/snapshot-test/test-1.image');
      expect(f.existsSync(), true);
    });

    test('getSnapshotFile, returns correct file for image', () async {
      final f = await Snapshot.getSnapshotFile('test-1.image', testOptions!);
      expect(f.path, './test/snapshot-test/test-1.image');
      expect(f.existsSync(), true);
    });

    test('getSnapshotFile, returns correct file for render tree', () async {
      final f = await Snapshot.getSnapshotFile('test-2.render', testOptions!);
      expect(f.path, './test/snapshot-test/test-2.render');
      expect(f.existsSync(), true);
    });

    test('getSnapshotFile, returns correct file for layer tree', () async {
      final f = await Snapshot.getSnapshotFile('test-3.layer', testOptions!);
      expect(f.path, './test/snapshot-test/test-3.layer');
      expect(f.existsSync(), true);
    });

    test('getFileName, returns correct file name for image', () async {
      expect(Snapshot.getFileName('id', SnapshotType.image), 'id.image');
    });

    test('getFileName, returns correct file name for render tree', () async {
      expect(Snapshot.getFileName('id', SnapshotType.render), 'id.render');
    });

    test('getFileName, returns correct file name for layer tree', () async {
      expect(Snapshot.getFileName('id', SnapshotType.layer), 'id.layer');
    });

    test('getExtenstion, returns correct file extenstion for image', () async {
      expect(Snapshot.getExtenstion(SnapshotType.image), 'image');
    });

    test('getExtenstion, returns correct file extenstion for render tree',
        () async {
      expect(Snapshot.getExtenstion(SnapshotType.render), 'render');
    });

    test('getExtenstion, returns correct file extenstion for layer tree',
        () async {
      expect(Snapshot.getExtenstion(SnapshotType.layer), 'layer');
    });

    test('getNewFileName, returns correct file name for image', () async {
      expect(Snapshot.getNewFileName('id', SnapshotType.image), 'id-new.image');
    });

    test('getNewFileName, returns correct file name for render tree', () async {
      expect(
          Snapshot.getNewFileName('id', SnapshotType.render), 'id-new.render');
    });

    test('getNewFileName, returns correct file name for layer tree', () async {
      expect(Snapshot.getNewFileName('id', SnapshotType.layer), 'id-new.layer');
    });

    test('getImgFileName, returns correct file name for png image', () async {
      expect(Snapshot.getImgFileName('id'), 'id.png');
    });

    test('getNewImgFileName, returns correct file name for png image',
        () async {
      expect(Snapshot.getNewImgFileName('id'), 'id-new.png');
    });

    test('toIntList, convets dynamic intergers to integer type', () async {
      expect(Snapshot.asIntList([100, 200]), [100, 200]);
    });
  });
}
