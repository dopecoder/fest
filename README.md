<h1 align="center">
  <br>
  <a href="https://www.github.com/dopecoder/fest"><img src="https://raw.githubusercontent.com/dopecoder/fest/master/images/fest.png" alt="Markdownify"></a>
  <br>
  Fest
  <br>  
  Flutter Snapshot Testing
  <br>
</h1>

<h4 align="center">
A simple snapshot testing utility for <a href="https://flutter.dev/" target="_blank">flutter</a> inspired by <a href="https://jestjs.io/" target="_blank">Jest</a>. Perform integration testing and compare snapshots ranging from Screenshots, Render Tree and Layer Tree.</h4>

<p align="center">
  <a href="https://pub.dev/packages/fest" rel="nofollow"><img src="https://raw.githubusercontent.com/dopecoder/fest/master/images/pub-badge.svg" alt="Pub Version" data-canonical-src="https://raw.githubusercontent.com/dopecoder/fest/master/images/pub-badge.svg" style="max-width:100%;"></a>
  <a href="https://gitter.im/fest-flutter/community"><img src="https://raw.githubusercontent.com/dopecoder/fest/master/images/gitter.svg"></a>
  <a href="https://saythanks.io/to/nramarao@hawk.iit.edu">
      <img src="https://img.shields.io/badge/SayThanks.io-%E2%98%BC-1EAEDB.svg">
  </a>
  <a href="https://www.paypal.me/NithinRao">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat">
  </a>
</p>

<p align="center">
  <a href="#key-features">Key Features</a> •
  <a href="#install">Install</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#how-to-use">Run</a> •
  <a href="#how-to-use">Email</a> •
  <a href="#credits">Credits</a> •
  <a href="#related">Related</a> •
  <a href="#license">License</a>
</p>

## Key Features

* Easy helper methods to perform snapshot testing of UI elements
* Compare snapshots such as Screensot, Render Tree and Layer Tree
* Remove dynamic text and widgets in your snapshot using Regex  
  - While we perform End to End testing or UI testing, its desirable that everything is mocked out, But for the projects which have dynamic content such as dates, timers etc can use regex to remove them from the snapshot.
* Cross platform
  - Windows, macOS and Linux ready.

## Install

### Add this package under dev_dependencies:
```
dev_dependencies:
  fest: ^0.1.2
```

### And then run:
```
flutter pub get
```

### Setup snapshot directory in the root of your project :
```
mkdir integration-tests
mkdir integration-tests/snaps
```

### Create a file named app.dart inside integration-tests directory with the following contents:
```dart
import 'package:flutter_driver/driver_extension.dart';
import 'package:<package>/main.dart' as app;

void main() {
  
  enableFlutterDriverExtension();

  app.main();
}
```

### Create app_test.dart inside integration-tests directory:
```dart
void main() {
  FlutterDriver? driver;
  Fest? snapTest;

  final splashScreenSelector = 'splash-screen'

  group('Resignal', () {
    setUpAll(() async {
      final opts = await SnapshotTestOptions.load();
      driver = await FlutterDriver.connect();
      snapTest = await Fest(driver: driver, options: opts);
    });

    tearDownAll(() async {
      driver?.close();
    });

    test('Test Login Screen', async () {
      await driver.waitForSelector('#$splashScreenSelector');
      await snapTest.matchRenderTreeSnapshot(splashScreenSelector);
    });
  });
}
```


## Running the tests

### Running CLI:
```bash
$ flutter pub run fest -h

flutter Snapshot Testing Tool
 --driver-path (-d)             Supply the absolute or relative path of the app driver (default: integration-tests/app.dart)
 --tests-path (-t)              Supply the absolute or relative path of the folder containing tests (default: integration-tests/)
 --snaps-path (-p)              Supply the absolute or relative path of the folder to store snapshots (default: integration-tests/snaps/)
 --update-snapshots (-u)        Update all snapshots (all tests passes and the new snapshots are saved)
 --help (-h)                    Help

```

### Running app_test.dart
```bash
$ flutter pub run fest
```
#### Note: When we run this for the first time, all the tests pass and the snapshot is captured. On the following runs, the new snapshot is compared with old snapshot.

### To update all snapshots:

```bash
$ flutter pub run fest -u
```

### To update a specific snapshot, we have to delete the exisiting snapshot file until an interactive test run can be implemented.

## How To Use

Using this package, we can easily perform snapshot testing using these following utility functions :

```dart
// This generates an image snapshot
Future<void> toMatchImageSnapshot(String id) async;
```

This creates a .image file which is list of integers representing the screenshot

```dart
// This generates a render tree snapshot
Future<void> toMatchRenderTreeSnapshot(String id, {List<RegExp>? removeExps}) async;
```

This creates a .render file which contains the complete render tree when the above function is executed


```dart
// This generates a layer tree snapshot
Future<void> toMatchLayerTreeSnapshot(String id, {List<RegExp>? removeExps}) async;
```


This creates a .layer file which is contains the complete layer tree when the above function is executed


## Advanced Usage

We can programatically remove parts if the render tree or layer tree which is currently dynamic, i.e. time, dates, coundowns etc. using regex.

The second argument for the above three helper methods is a list of regex to remove form the snapshot.

Note: If we add a regex after a snapshot has been created, we need to delete than snapshot and recteate it.

## Email

Fest is an Snapshot Testing tool. Meaning, if you liked using this app or it has helped you in any way, I'd like you send me an email at <nithinhrao@gmail.com> about anything you'd want to say about this software. I'd really appreciate it!

## Credits

This software uses the following open source packages:

- [Dart](https://dart.dev/)
- [Flutter](https://flutter.dev/)
- [Jest](https://jestjs.io/)
- [Mockito](https://pub.dev/packages/mockito)
- [Args](https://pub.dev/packages/args)
- [Build Runner](https://pub.dev/packages/build_runner)
- [Equatable](https://pub.dev/packages/equatable)
- Emojis are taken from [here](https://github.com/arvida/emoji-cheat-sheet.com)

## Related

[integration-testing](https://flutter.dev/docs/cookbook/testing/integration/introduction) - Flutter Integration testing

## Support

<a href="https://www.buymeacoffee.com/nithinrao" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

<!-- <p>Or</p> 

<a href="https://www.patreon.com/nithinrao">
	<img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160">
</a> -->


## License

MIT

---

> GitHub [@dopecoder](https://github.com/dopecoder) &nbsp;&middot;&nbsp;
> Twitter [@dopecoder](https://twitter.com/dopecoder)

