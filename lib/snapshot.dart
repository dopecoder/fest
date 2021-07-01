import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:fest/extensions.dart';
import 'package:fest/options.dart';

enum SnapshotType { image, render, layer }

class Snapshot {
  final String id;
  final String? render;
  final String? layer;
  final List<int>? image;
  late final SnapshotType type;

  Snapshot(this.id, {this.render, this.layer, this.image}) {
    if (render != null) {
      type = SnapshotType.render;
    } else if (layer != null) {
      type = SnapshotType.layer;
    } else if (image != null) {
      type = SnapshotType.image;
    } else {
      throw Exception('Snapshot: Incorrect construction of Snapshot');
    }
  }

  static Future<Snapshot?> getSnapshotFromDriver(String id, SnapshotType type,
      FlutterDriver driver, List<RegExp>? removeExps) async {
    try {
      switch (type) {
        case SnapshotType.image:
          return Snapshot(id, image: (await driver.screenshot()));
        case SnapshotType.render:
          final json = (await driver.getRenderTree()).toJson();
          var s = json['tree'].toString().cleanupTree();
          s = removeExps != null ? s.removeFromList(removeExps) : s;
          return Snapshot(id, render: s);
        case SnapshotType.layer:
          final json = (await driver.getLayerTree()).toJson();
          var s = json['tree'].toString().cleanupTree();
          s = removeExps != null ? s.removeFromList(removeExps) : s;
          return Snapshot(id, layer: s);
      }
    } catch (e) {
      print(
          'SnapshotTest: (getSnapshotFromDriver) snapshot from driver failed for type - $type - $e');
    }
  }

  static Future<Snapshot?> getSnapshotFromFile(
      String id, SnapshotType type, SnapshotTestOptions options) async {
    final fileName = getFileName(id, type);
    try {
      final file = await getSnapshotFile(fileName, options);
      final contents = await file.readAsString();
      switch (type) {
        case SnapshotType.image:
          return Snapshot(id, image: asIntList(jsonDecode(contents)));
        case SnapshotType.render:
          return Snapshot(id, render: contents);
        case SnapshotType.layer:
          return Snapshot(id, layer: contents);
      }
    } catch (e) {
      print(
          'SnapshotTest: (getSnapshotFromFile) snapshot file $fileName not found! - $e');
    }
  }

  dynamic getSnapshotData() {
    switch (type) {
      case SnapshotType.image:
        return image;
      case SnapshotType.render:
        return render;
      case SnapshotType.layer:
        return layer;
    }
  }

  void matchesSnapshot(Snapshot newSnapshot) {
    if (type != newSnapshot.type) {
      throw Exception('Snapshot: Cannot compare snapshots of different types');
    }

    var prevSnap = getSnapshotData();
    var newSnap = newSnapshot.getSnapshotData();

    if (prevSnap is List && newSnap is List) {
      expect(prevSnap, newSnap);
      return;
    } else if (prevSnap is String && newSnap is String) {
      expect(prevSnap, newSnap);
      return;
    }
  }

  Future<bool> save(SnapshotTestOptions opts, {bool? asNew}) async {
    var fileName = getFileName(id, type);
    fileName =
        asNew != null && asNew == true ? getNewFileName(id, type) : fileName;
    try {
      final fileOld = await getSnapshotFile(fileName, opts);
      await fileOld.create();
      final data = getSnapshotData();
      if (data is String) {
        await fileOld.writeAsString(data);
      } else if (data is List<int>) {
        await fileOld.writeAsString(jsonEncode(data));
      }
      return true;
    } catch (e) {
      print('SnapshotTest: (save) failed writing data to file! - $e');
    }
    return false;
  }

  Future<bool> saveImage(SnapshotTestOptions opts, List<int>? img,
      {bool? asNew}) async {
    if (img == null) {
      return false;
    }
    var fileName = getImgFileName(id);
    fileName =
        asNew != null && asNew == true ? getNewImgFileName(id) : fileName;
    try {
      final file = await getSnapshotFile(fileName, opts);
      await file.create();
      await file.writeAsBytes(img);
      return true;
    } catch (e) {
      print('SnapshotTest: (save) failed writing image to file! - $e');
    }
    return false;
  }

  @visibleForTesting
  static Future<File> getSnapshotFile(
      String filename, SnapshotTestOptions opts) async {
    var path = opts.snapshotDirPath;
    if (path[path.length - 1] == '/') {
      path = path.substring(0, path.length - 1);
    }
    return File('$path/$filename');
  }

  @visibleForTesting
  static String getFileName(String id, SnapshotType type) {
    final ext = getExtenstion(type);
    return '$id.$ext';
  }

  @visibleForTesting
  static String getExtenstion(SnapshotType type) {
    if (type == SnapshotType.layer) {
      return 'layer';
    } else if (type == SnapshotType.render) {
      return 'render';
    } else if (type == SnapshotType.image) {
      return 'image';
    }
    return '';
  }

  @visibleForTesting
  static String getNewFileName(String id, SnapshotType type) {
    final ext = getExtenstion(type);
    return '$id-new.$ext';
  }

  @visibleForTesting
  static String getImgFileName(String id) {
    return '$id.png';
  }

  @visibleForTesting
  static String getNewImgFileName(String id) {
    return '$id-new.png';
  }

  @visibleForTesting
  static List<int> asIntList(List<dynamic> list) =>
      list.map((n) => n as int).toList();
}
