import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'package:fest/options.dart';
import 'package:fest/snapshot.dart';

class Fest {
  final FlutterDriver driver;
  late SnapshotTestOptions options;

  Fest({required this.driver, SnapshotTestOptions? options}) {
    this.options =
        options ?? SnapshotTestOptions.defaultOptions(projectPath: '.');
  }

  Future<void> toMatchImageSnapshot(String id,
      {List<RegExp>? removeExps}) async {
    final currentSnapshot =
        await Snapshot.getSnapshotFromFile(id, SnapshotType.image, options);
    final newSnapshot = await Snapshot.getSnapshotFromDriver(
        id, SnapshotType.image, driver, removeExps);

    if (newSnapshot == null) {
      throw Exception(
          'SnapshotTest: (toMatchRenderTreeSnapshot) New Snapshot is null');
    }

    if (currentSnapshot == null || options.forceCaptureMode) {
      await newSnapshot.save(options);
      return;
    }

    try {
      currentSnapshot.matchesSnapshot(newSnapshot);
      return;
    } on TestFailure catch (_) {
      await saveFailure(currentSnapshot, newSnapshot);
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> toMatchRenderTreeSnapshot(String id,
      {List<RegExp>? removeExps}) async {
    final currentSnapshot =
        await Snapshot.getSnapshotFromFile(id, SnapshotType.render, options);
    final newSnapshot = await Snapshot.getSnapshotFromDriver(
        id, SnapshotType.render, driver, removeExps);

    if (newSnapshot == null) {
      throw Exception(
          'SnapshotTest: (toMatchRenderTreeSnapshot) New Snapshot is null');
    }

    if (currentSnapshot == null || options.forceCaptureMode) {
      await newSnapshot.save(options);
      await captureScreenshot(id);
      return;
    }

    try {
      currentSnapshot.matchesSnapshot(newSnapshot);
      return;
    } on TestFailure catch (_) {
      await captureScreenshot(id, asNew: true);
      await saveFailure(currentSnapshot, newSnapshot);
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> toMatchLayerTreeSnapshot(String id,
      {List<RegExp>? removeExps}) async {
    final currentSnapshot = await Snapshot.getSnapshotFromFile(
      id,
      SnapshotType.layer,
      options,
    );
    final newSnapshot = await Snapshot.getSnapshotFromDriver(
        id, SnapshotType.layer, driver, removeExps);
    if (newSnapshot == null) {
      throw Exception(
          'SnapshotTest: (toMatchLayerTreeSnapshot) New Snapshot is null');
    }

    if (currentSnapshot == null || options.forceCaptureMode) {
      await newSnapshot.save(options);
      await captureScreenshot(id);
      return;
    }

    try {
      currentSnapshot.matchesSnapshot(newSnapshot);
      return;
    } on TestFailure catch (_) {
      await captureScreenshot(id, asNew: true);
      await saveFailure(currentSnapshot, newSnapshot);
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> captureScreenshot(String id, {bool? asNew}) async {
    List<int>? sh;
    try {
      sh = await driver.screenshot();
    } catch (e) {
      print('Error capturing screenshot - $e');
    }
    if (sh != null) {
      final snap = Snapshot(id, image: sh);
      await snap.saveImage(options, sh, asNew: asNew);
    }
  }

  Future<bool> saveFailure(Snapshot o, Snapshot n) async {
    await o.save(options);
    await n.save(options, asNew: true);
    return true;
  }
}
